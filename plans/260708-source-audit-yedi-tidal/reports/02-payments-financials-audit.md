# Audit Thanh toán & Tài chính — Yedi/Tidal API

**Phạm vi:** toàn bộ logic tính tiền, sinh hóa đơn (invoice), phiếu lương (payslip), hợp đồng (contract), cast tiền tệ, idempotency, mô hình payroll.
**Codebase:** `source/yedi-tidal-api` (Laravel 11, PHP 8.2, `brick/money` GBP).
**Ngày:** 2026-07-08.

---

## 0. Bối cảnh thương mại — "Tiền không bao giờ DI CHUYỂN"

Xác nhận từ `composer.json`: **KHÔNG có payment gateway** (không Stripe/Cashier/PayPal/Braintree). Hệ thống chỉ **TÍNH toán con số** và **render PDF** rồi gửi qua DocGen. Không có xử lý giao dịch, không ledger, không đối soát (reconciliation), không webhook thanh toán.

Luồng tiền thực tế (suy ra từ source):
- Platform **xuất hóa đơn cho advertiser** = tổng lương gộp (`advertiser_pay_rate` × số lượng) **+ VAT 20%**. Advertiser trả bằng **chuyển khoản ngân hàng thủ công** — số tài khoản/sort code lấy từ `Settings` và in trên `invoice.blade.php` (dòng 147-149).
- Platform giữ **margin** = `advertiserCharge` + `applicantCharge` (= `profit`), phần còn lại `applicantPay` trả cho applicant.
- Việc **trả tiền cho applicant** (và toàn bộ payroll/PAYE/NI/pension) diễn ra **NGOÀI hệ thống** — không được mô hình hóa ở bất kỳ đâu (xem F4). Payslip lẽ ra phản ánh khoản net này nhưng đang **rỗng** (xem F1).

**Hệ quả:** đây là hệ thống *tính toán + sinh chứng từ*, không phải hệ thống *thanh toán*. Mọi con số đúng/sai phụ thuộc hoàn toàn vào công thức trong `Advert.php` và các Job — không có cơ chế đối chiếu với dòng tiền thật.

### Đính chính so với báo cáo black-box ("old claim → source truth")
Black-box kết luận việc sinh billing **"vắng mặt tuyệt đối / không có engine"**. **SAI.** Source cho thấy **engine sinh chứng từ TỒN TẠI**:
- Connector Saloon `DocGenConnector` (HTTP Basic) + `GeneratePdfRequest`.
- Job hàng đợi: `CreateAdvertInvoiceJob`, `CreateAdvertPayslipJob`, `CreateAdvertiserContractJob`, `CreateApplicantContractJob`.
- Model `Invoice`/`InvoiceItem`/`Payslip`/`Contract`, blade `invoice.blade.php`, trigger qua `MarkAdvertsAsCompleteCommand` (chạy mỗi phút).

**Đính chính chính xác:** engine **CÓ tồn tại nhưng CHƯA HOÀN THIỆN và có lỗ hổng tài chính** — invoice tương đối đầy đủ, nhưng **payslip là stub rỗng**, **không có payroll/thuế**, và **thiếu idempotency/retry**.

---

## 1. Phân tích tính đúng đắn công thức (`app/Models/Advert.php`)

Các công thức lõi (đều `RoundingMode::HALF_UP`, GBP scale = 2 chữ số thập phân/pennies):

| Attribute | Công thức | Dòng |
|---|---|---|
| `advertiserChargeRate` | `pay_rate × (advertiser_charge_percentage / 100)` | 150-155 |
| `applicantChargeRate` | `(pay_rate − advertiserChargeRate) × (applicant_charge_percentage / 100)` | 173-178 |
| `applicantPayRate` | `pay_rate − advertiserChargeRate − applicantChargeRate` | 196-208 |
| `totalAdvertiserPay` | Hourly: Σ(pay_rate × shift.hours); Daily: pay_rate × count(shifts) | 135-147 |
| `profit` | `total_advertiser_pay − applicant_pay` | 224-229 |

**Nơi các attribute này thực sự được dùng** (grep toàn repo):
- `Filament/Widgets/ExpenditureOverview.php` — chỉ số dashboard admin.
- `Http/Resources/Adverts/AdvertResource.php:66-67` — trả `applicant_pay`/`applicant_pay_rate` cho app.
- **KHÔNG được dùng trong invoice/payslip.** Invoice tính lại độc lập từ `advertiser_pay_rate` gộp (xem §Idempotency & F-list). Payslip không dùng gì cả (rỗng).

Nhận xét đúng đắn:
- **Nhất quán invoice ↔ totalAdvertiserPay:** invoice subtotal (Job dòng 70) = Σ(pay_rate × quantity) khớp với `totalAdvertiserPay`. ✅
- **HALF_UP (không phải banker's rounding):** Brick `HALF_UP` làm tròn nửa lên (away-from-zero), **không** phải `HALF_EVEN`. Nhất quán ở mọi nơi — chấp nhận được cho hóa đơn, nhưng cần ghi nhận đây là lựa chọn có thiên lệch làm tròn lên nhẹ.
- **Mass-assignment charge %:** `CreateAdvertHandler` (56-57) ghi đè `applicant/advertiser_charge_percentage` từ `Settings` **SAU** khi spread `$data->toArray()`, và request `CreateAdvertRequest` không validate 2 field này → advertiser **không** tự set được. ✅ Charge % được *snapshot* lên hàng `adverts` tại thời điểm tạo (bảo toàn lịch sử khi settings đổi về sau). ✅

Các vấn đề đúng đắn xem F5, F6, F7 bên dưới.

---

## Danh sách phát hiện

### 🔴 F1 — Payslip PDF RỖNG, không có bất kỳ số tiền nào
**Severity:** 🔴 Critical
**File:** `resources/views/pdfs/payslip.blade.php:34-36`; model `app/Models/Payslip.php`; migration `2025_01_24_093814_create_payslips_table.php`

**Mô tả:** Toàn bộ nội dung payslip là `<h1>Payslip: #000001</h1>`. Không có gross, net, số giờ, rate, khấu trừ, thuế, NI — không gì cả. Bảng `payslips` **không có cột tiền nào** (chỉ `title`, `payslip_number`, FK advert/applicant/upload). `CreateAdvertPayslipJob` cũng không tính/lưu tiền — chỉ tạo record rồi render blade rỗng.

**Tác động tài chính:** Applicant nhận được một "phiếu lương" **không có thông tin lương**. Vô dụng về mặt kế toán, không thể dùng làm chứng từ thu nhập, không đáp ứng yêu cầu payslip hợp pháp của UK (Employment Rights Act 1996 s.8 yêu cầu itemised pay statement: gross, các khoản khấu trừ, net). Đây là chức năng lõi bị **bỏ dở**.

**Khuyến nghị:** Thêm cột tiền (gross/net/tax/NI/hours/rate) vào `payslips` hoặc tính từ `advert->applicant_pay`; dựng lại blade payslip đầy đủ hàng mục; nếu platform là agency/employer thì phải đưa khấu trừ PAYE/NI vào (xem F4).

---

### 🔴 F2 — Không có ràng buộc idempotency → hóa đơn/phiếu lương TRÙNG LẶP
**Severity:** 🔴 Critical
**File:** `app/Console/Commands/Adverts/MarkAdvertsAsCompleteCommand.php:33-47`; `bootstrap/app.php:65`; migrations `create_invoices_table` / `create_payslips_table`

**Mô tả:** Nhiều tầng đều thiếu chốt idempotency:
1. Bảng `invoices`/`payslips` **không có unique index** trên `advert_id`. Quan hệ `hasOne` chỉ là quy ước ORM, DB không chặn 2 invoice cho cùng 1 advert.
2. `MarkAdvertsAsCompleteCommand` chạy `->everyMinute()` (`bootstrap/app.php:65`) **không có `withoutOverlapping()`** (đã grep: NONE trong toàn repo). Command duyệt bằng `cursor()`; nếu một lần chạy kéo dài > 60s, lần chạy kế tiếp có thể chọn cùng advert (vì `marked_as_completed_at` chưa kịp set) → dispatch **2 lần** `CreateAdvertInvoiceJob` + `CreateAdvertPayslipJob`.
3. Job không dùng `ShouldBeUnique`/`uniqueId`.

**Tác động tài chính:** Advertiser có thể nhận **2 hóa đơn cho cùng một advert** (với `invoice_number` khác nhau vì sinh từ `id` tự tăng), dẫn tới đòi tiền trùng/tranh chấp. Applicant nhận payslip trùng. Không có cơ chế phát hiện.

**Khuyến nghị:** Thêm unique index `advert_id` trên `invoices` và `payslips`; áp `withoutOverlapping()` cho command; hoặc cho job implement `ShouldBeUnique` với `uniqueId = advert_id`.

---

### 🟠 F3 — Job không retry, không dead-letter → DocGen sập = mất chứng từ VĨNH VIỄN (âm thầm)
**Severity:** 🟠 High
**File:** `config/horizon.php:194` (`'tries' => 1`); `app/Jobs/CreateAdvertInvoiceJob.php`, `CreateAdvertPayslipJob.php` (không có `$tries`, `$backoff`, `retryUntil()`, `failed()`); `MarkAdvertsAsCompleteCommand.php:42-45`

**Mô tả:** Horizon cấu hình `tries = 1`. Các Job **không** khai báo `$tries`, `$backoff`, `retryUntil()` hay `failed()` handler (đã grep: không có). Quan trọng hơn: command **set `marked_as_completed_at = now()` TRƯỚC** rồi mới dispatch job (dòng 42 → 44-45). Guard chọn advert là `whereNull('marked_as_completed_at')`. Nên một khi advert đã đánh dấu complete:
- Nếu DocGen down/timeout → job vào `failed_jobs`, **không tự retry**.
- Advert **sẽ không bao giờ được xử lý lại** (đã hết `null`), nên invoice/payslip **mất luôn** mà không có cảnh báo nghiệp vụ (chỉ có Sentry report kỹ thuật).

**Tác động tài chính:** Trong một đợt DocGen gián đoạn, hàng loạt advert hoàn tất sẽ **không có hóa đơn** → platform **không đòi được tiền advertiser**; applicant không có payslip. Thất thoát doanh thu âm thầm, chỉ phát hiện khi đối soát thủ công.

**Khuyến nghị:** Tăng `tries` + `backoff` cho job tài chính; thêm `failed()` để cảnh báo; tách trạng thái "đã complete" khỏi "đã sinh chứng từ" (cột `invoiced_at`/`payslip_generated_at` riêng) để có thể quét lại; hoặc chỉ set `marked_as_completed_at` sau khi job thành công.

---

### 🟠 F4 — KHÔNG có mô hình payroll/thuế (PAYE / National Insurance / pension / umbrella)
**Severity:** 🟠 High
**File:** toàn hệ thống — grep `tax|PAYE|national insurance|NI|umbrella|gross|net|deduction` chỉ khớp **VAT** trên invoice; không nơi nào mô hình hóa payroll.

**Mô tả:** Payslip ngụ ý có quan hệ lao động/chi trả lương, nhưng hệ thống **không có bất kỳ khái niệm nào** về: thu nhập gộp vs net, khấu trừ thuế thu nhập (PAYE), National Insurance (nhân viên + chủ lao động), pension auto-enrolment, tax code, umbrella company. `applicantPay` chỉ là *pay gộp trừ margin platform* — vẫn là **gross**, chưa trừ thuế.

**Tác động tài chính / pháp lý:** Với thị trường staffing UK, đây là lỗ hổng compliance nghiêm trọng nếu platform đóng vai trò agency/employer. Không rõ mô hình vận hành là: (a) applicant tự lo thuế (self-employed) — thì cần rõ ràng trên chứng từ; (b) có umbrella/agency PAYE bên ngoài — thì payslip phải đến từ bên đó, không phải hệ thống này. **Cần làm rõ giả định vận hành với khách hàng.**

**Khuyến nghị:** Xác định rõ mối quan hệ pháp lý (self-employed vs PAYE vs umbrella). Nếu PAYE: cần module payroll đầy đủ (hoặc tích hợp payroll provider), không thể phát payslip "gross" tự chế.

---

### 🟠 F5 — Charge % ở cấp Advert (Filament) không validate min/max → pay ÂM
**Severity:** 🟠 High
**File:** `app/Filament/Resources/AdvertResource.php:154-161`

**Mô tả:** Input `advertiser_charge_percentage` và `applicant_charge_percentage` trên form Advert chỉ có `->numeric()->required()`, **thiếu `minValue`/`maxValue`** (khác với `System.php:66-72` nơi settings mặc định được giới hạn `minValue(0)->maxValue(100)`). Admin sửa advert có thể nhập > 100 hoặc số âm.

**Tác động tài chính:** Nếu `advertiser_charge_percentage > 100`: `advertiserChargeRate > pay_rate` → `applicantChargeRate` âm → `applicantPayRate = pay − advertiserCharge − applicantCharge` **ÂM** → applicant "pay" âm hiển thị trong app (`AdvertResource:66`) và trong dashboard profit. Số âm này lan vào widget `ExpenditureOverview` làm sai lệch báo cáo doanh thu.

**Khuyến nghị:** Áp `->minValue(0)->maxValue(100)` cho cả 2 input; thêm ràng buộc `advertiser_% + applicant_%` hợp lý; validate cấp DB/model để mọi đường ghi đều an toàn.

---

### 🟡 F6 — Làm tròn "rate trước, nhân sau" gây sai lệch pennies theo giờ/ca
**Severity:** 🟡 Medium
**File:** `app/Models/Advert.php:150-193` (advertiser/applicant charge Hourly)

**Mô tả:** Với Hourly, `advertiserChargeRate`/`applicantChargeRate` được **làm tròn về pennies TRƯỚC** (dòng 153, 176), rồi mới nhân `shift.hours` và làm tròn lại từng ca (165, 188). Đây là "round-then-multiply" thay vì "multiply-then-round". Với rate lẻ (vd pay £10.33 × 15% = £1.5495 → làm tròn £1.55/giờ), sai số nhân lên theo số giờ và số ca, lệch vài pennies so với tính trên tổng.

**Tác động tài chính:** Sai lệch nhỏ (pennies) nhưng **tích lũy** khi nhiều ca/nhiều giờ; và vì margin platform = hiệu của các con số đã làm tròn riêng, tổng advertiserCharge+applicantCharge có thể không khớp chính xác `pay − applicantPay`.

**Khuyến nghị:** Chuẩn hóa một quy tắc: tính trên tổng rồi mới làm tròn một lần cuối, hoặc dùng `Money::allocate`/`split` của Brick để phân bổ không mất pennies.

---

### 🟡 F7 — Line item hóa đơn: `quantity` lưu decimal(8,2) nhưng `amount` tính từ float đầy đủ
**Severity:** 🟡 Medium
**File:** `app/Jobs/CreateAdvertInvoiceJob.php:58-67`; migration `2025_02_04_101446_fix_invoice_items_quantity_column.php`; `Shift::getHoursAttribute` (`minutes/60`)

**Mô tả (bao gồm điều tra migration `fix_invoice_items_quantity_column`):** Migration gốc `add_new_invoice_fields.php:33` tạo cột `invoice_items.quantity` kiểu **`json`** (sai — quantity là số). Migration `fix_invoice_items_quantity_column` sửa thành `->decimal('quantity')` (mặc định precision **8,2 → chỉ 2 chữ số thập phân**). Trong khi đó `shift->hours = minutes/60` có thể là số lẻ vô hạn (vd 440 phút → 7.3333h). Job dùng **float đầy đủ** để tính `amount = pay_rate × quantity` (dòng 66), nhưng **lưu** quantity đã cắt còn 2 chữ số (7.33). Kết quả: trên PDF, `rate × quantity_hiển_thị ≠ amount` (vd £10 × 7.33 = £73.30 nhưng amount hiển thị £73.33).

**Tác động tài chính:** Hóa đơn có dòng mà "đơn giá × số lượng" không bằng "thành tiền" → advertiser thắc mắc/tranh chấp, trông thiếu chuyên nghiệp. Subtotal vẫn khớp `totalAdvertiserPay` nên tổng đúng, chỉ dòng chi tiết mâu thuẫn.

**Khuyến nghị:** Tăng precision cột quantity (vd decimal(8,4)) hoặc làm tròn số giờ nhất quán trước cả khi tính amount lẫn khi lưu, để dòng hóa đơn tự nhất quán.

---

### 🟡 F8 — Đánh dấu complete tách rời khỏi dispatch (không nguyên tử)
**Severity:** 🟡 Medium
**File:** `app/Console/Commands/Adverts/MarkAdvertsAsCompleteCommand.php:42-46`

**Mô tả:** `$advert->update(['marked_as_completed_at' => now()])` (dòng 42) và `dispatch()` (44-45) **không cùng transaction**. Nếu tiến trình chết/deploy/OOM giữa 2 bước, advert đã bị đánh dấu complete nhưng job chưa vào hàng đợi → không invoice, không tự phục hồi (trùng nguyên nhân gốc với F3).

**Tác động tài chính:** Mất hóa đơn/payslip lặng lẽ cho các advert dính đúng thời điểm crash.

**Khuyến nghị:** Bọc trong transaction + `dispatch()->afterCommit()`, hoặc dùng cột trạng thái riêng cho "đã sinh chứng từ" để quét lại (xem F3).

---

### 🟢 F9 — VAT hardcode 20% trong Job
**Severity:** 🟢 Low
**File:** `app/Jobs/CreateAdvertInvoiceJob.php:71`

**Mô tả:** `$vat = $subtotal->multipliedBy(0.2, HALF_UP)` — thuế suất VAT **cứng 0.2**, không đọc từ `Settings`, không hỗ trợ advertiser miễn VAT, reverse-charge, hay thay đổi thuế suất pháp lý. (Ghi nhận tích cực: **VAT CÓ được tính và lưu** — trái với lo ngại "không có VAT"; nó chỉ thiếu cấu hình.)

**Tác động tài chính:** Nếu thuế suất VAT thay đổi hoặc có advertiser đặc thù, phải sửa code. Nguy cơ xuất hóa đơn sai VAT cho khách miễn thuế.

**Khuyến nghị:** Đưa VAT rate vào `Settings`; hỗ trợ cờ miễn VAT ở cấp advertiser.

---

### 🟢 F10 — pay_rate cho phép £0; không unique cho invoice_number/payslip_number
**Severity:** 🟢 Low
**File:** `app/Http/Requests/Advertiser/Adverts/CreateAdvertRequest.php:36` (`'min:0'`); `Invoice.php:37-43`, `Payslip.php:23-29`

**Mô tả:** `advertiser_pay_rate` validate `min:0` → cho phép advert £0 → invoice/payslip £0 (kèm VAT £0). `invoice_number`/`payslip_number` sinh từ `id` (`INV000001`) nhưng **không có unique index DB** trên cột số hiệu.

**Tác động tài chính:** Advert £0 tạo chứng từ vô nghĩa; thiếu unique index về lý thuyết cho phép trùng số hiệu nếu logic sinh bị gọi lại.

**Khuyến nghị:** `min:0.01` (hoặc min nghiệp vụ) cho pay_rate; thêm unique index cho các cột số hiệu chứng từ.

---

### 🟢 F11 — `SettingsResolver::firstOrFail()` là điểm gãy đơn lẻ cho Job hóa đơn
**Severity:** 🟢 Low
**File:** `app/Handlers/Settings/SettingsResolver.php:17-20`; `CreateAdvertInvoiceJob.php:44`

**Mô tả:** `Settings::query()->latest()->firstOrFail()` — nếu chưa có bản ghi Settings, ném `ModelNotFoundException` làm `CreateAdvertInvoiceJob` fail (kết hợp F3 → mất hóa đơn). `invoice_due_date_days`/`late_payment_charge_percent` lấy từ Settings **hiện tại** (không snapshot theo thời điểm advert tạo — khác với charge % vốn được snapshot lên advert). Sai lệch nhỏ về nhất quán thời điểm.

**Khuyến nghị:** Có Settings mặc định seed sẵn; cân nhắc snapshot điều khoản hóa đơn tại thời điểm sinh.

---

## 2. Tính toàn vẹn & Audit trail (điểm tích cực)
- **`brick/money`** dùng đúng minor units (pennies) qua `MoneyCast` (`getMinorAmount`/`ofMinor`) — tránh sai số float cho tiền. ✅
- Invoice **snapshot** `sub_total`/`vat`/`total` (persisted), không tính lại khi đọc → chứng từ hóa đơn bất biến. ✅ (Ngược lại, payslip/applicant_pay **tính lại mỗi lần đọc** từ advert — rủi ro nếu shift/percentage đổi sau hoàn tất; nhưng percentage đã snapshot trên advert nên rủi ro thấp.)
- `owen-it/laravel-auditing` bật trên `Advert`, `Invoice`, `InvoiceItem`, `Payslip`, `Settings` → có audit trail thay đổi. ✅
- Job invoice/payslip bọc trong `DB::transaction` + rollback đúng. ✅

---

## Bảng tổng hợp theo Severity

| # | Phát hiện | Severity | File chính |
|---|---|---|---|
| F1 | Payslip PDF rỗng, không có số tiền | 🔴 Critical | `pdfs/payslip.blade.php:35` |
| F2 | Không có idempotency → invoice/payslip trùng lặp | 🔴 Critical | `MarkAdvertsAsCompleteCommand.php:33-47` |
| F3 | Job không retry/dead-letter → DocGen sập = mất chứng từ | 🟠 High | `horizon.php:194`, Jobs |
| F4 | Không mô hình payroll/thuế (PAYE/NI/umbrella) | 🟠 High | toàn hệ thống |
| F5 | Charge % cấp advert không validate min/max → pay âm | 🟠 High | `AdvertResource.php:154-161` |
| F6 | Làm tròn rate-trước-nhân-sau → lệch pennies | 🟡 Medium | `Advert.php:150-193` |
| F7 | quantity decimal(8,2) vs amount float → line item lệch | 🟡 Medium | `CreateAdvertInvoiceJob.php:58-67` |
| F8 | Mark-complete tách rời dispatch (không nguyên tử) | 🟡 Medium | `MarkAdvertsAsCompleteCommand.php:42-46` |
| F9 | VAT hardcode 20% | 🟢 Low | `CreateAdvertInvoiceJob.php:71` |
| F10 | pay_rate cho phép £0; thiếu unique số hiệu | 🟢 Low | `CreateAdvertRequest.php:36` |
| F11 | SettingsResolver firstOrFail là SPOF | 🟢 Low | `SettingsResolver.php:17` |

**Tổng: 2 Critical · 3 High · 3 Medium · 3 Low.**

---

## Câu hỏi chưa giải đáp (cần làm rõ với khách hàng)
1. **Mô hình lao động:** applicant là self-employed, PAYE, hay qua umbrella company? Quyết định này định đoạt mức độ nghiêm trọng của F1/F4 (payslip rỗng + thiếu thuế).
2. **Payslip:** có phải chức năng bị bỏ dở giữa chừng (stub) hay chủ ý để bên payroll ngoài lo? Nếu chủ ý thì tại sao vẫn sinh record + PDF rỗng?
3. **Thanh toán applicant:** platform trả tiền applicant qua kênh nào (không thấy trong source)? Có cần tích hợp/ghi nhận trong hệ thống không?
4. **VAT:** platform có luôn VAT-registered và mọi advertiser đều chịu 20% không, hay cần miễn/reverse-charge?
