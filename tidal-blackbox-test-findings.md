# Black-box Test — Bằng chứng hành vi (không phải suy đoán từ list rỗng)

> Test trực tiếp trên LIVE production (`admin.tidalagency.co.uk`), có phép của khách, ngày 2026-06-29.
> 4 agent chạy song song, mỗi agent 1 browser session riêng, chỉ thao tác record test tự tạo rồi xoá.
> **Cleanup đã verify:** production về baseline (1 advert Kering, 0 application/invoice/payslip/required-evidence/declaration).
> Evidence: `evidences/blackbox/*.png` (47 ảnh).

## Vì sao có report này

Trước đó các finding "0 records → missing" chỉ dựa trên **UI list rỗng** = chứng minh *data rỗng*, KHÔNG chứng minh *logic thiếu*. Report này chạy thử FLOW thật để lấy **bằng chứng hành vi**: tạo record, submit, quan sát hệ thống phản ứng → phân biệt được "logic chạy / dở dang / không có".

---

## Finding 1 — Chuỗi giao dịch: Application CHẠY, nhưng dừng trước khâu tiền tệ

**Đã verify bằng hành vi (tạo Accepted application thật rồi xoá):**
- ✅ **Tạo Application CHẠY THẬT** — form (Candidate/Advert/Status) lưu DB OK, hiện trong list. (evidence: `t1-application-create.png`, `t1-applications-list.png`)
- ✅ **Logic aggregation/quan hệ CHẠY THẬT** — sau khi set Accepted:
  - Advert id=1 field **"Accepted application" tự cập nhật** = Apple Candidate (trước rỗng).
  - Candidate cột **Accepted = 1** (trước 0). (evidence: `t1-advert-1.png`, `t1-candidates-list.png`)
- ❌ **KHÔNG có entity Booking/Allocation** riêng — chỉ là quan hệ application↔advert↔candidate.
- ❌ **Advert status KHÔNG tự đổi** sang "Filled" khi có Accepted application (không có side-effect state).
- ❌ **KHÔNG auto-gen Invoice/Payslip** — sau Accepted, Invoices/Payslips vẫn rỗng, Dashboard vẫn £0. (evidence: `t1-invoices-after.png`, `t1-payslips-after.png`)
- ❌ **KHÔNG có action thủ công** nào để tiến chuỗi (không "Allocate/Confirm/Generate") trên application, advert, hay candidate.

> **Kết luận:** chuỗi `Application → Booking → Invoice → Payslip` mới chạy tới **Application + cập nhật quan hệ phái sinh**. Khâu Booking và khâu tiền tệ (Invoice/Payslip) **không có trigger nào tồn tại** — đây là bằng chứng hành vi, không còn là suy đoán.

---

## Finding 2 — Invoice/Payslip generation: VẮNG MẶT (xác nhận tuyệt đối)

Audit toàn bộ action trên mọi resource (`t4-*`):
- Invoices & Payslips: **chỉ có Search + Toggle columns**, KHÔNG nút New/Generate/Create/Export. (evidence: `t4-invoices-actions.png`, `t4-payslips-actions.png`)
- KHÔNG có action "Generate invoice/payslip" ở Adverts, Applications, Candidates — không ở đâu cả.

> **Kết luận:** generation engine **chưa wire vào UI ở bất kỳ điểm nào**. Bằng chứng mạnh nhất có thể có mà không cần source: không tồn tại đường nào (manual hay auto) để sinh invoice/payslip từ UI.

---

## Finding 3 — Compliance: một nửa engine thật, một nửa vỡ

- ✅ **Required Evidence CRUD CHẠY** — create qua **modal/slide-over** (vì vậy route `/create` trống), tạo & lưu & hiện list OK. (evidence: `t2-required-evidence-modal.png`, `t2-required-evidence-created.png`)
- ✅ **Candidate có EVIDENCE DATA THẬT** — tab Identification: **Photograph, Evidence of ID (ảnh), Video verification (video player), ID number**; tab Contracts: **hợp đồng "Tidal Employment Contract Feb 17" + file link**. (evidence: `t2-candidate-identification-tab.png`, `t2-candidate-contracts-tab.png`)
  → **Storage model cho evidence là thật.** NHƯNG (xem Finding 6) **không có front-end candidate live** để capture — nên data này **nhiều khả năng là dev/test seed** (mọi candidate đều `@ne6.studio`), KHÔNG phải bằng chứng pipeline đang chạy. Chỉ schema lưu trữ tái dùng được; phần capture vẫn build mới.
- ✅ **References workflow có thật** — modal "Update references": repeater Name/Telephone/Email/Status (= "Sent to Referee"). (evidence: `t2-update-references-modal.png`)
- ✅ **Compliance status** = 4 trạng thái (Incomplete/Pending Approval/Compliant/Non Compliant), set qua "Update status". (evidence: `t2-update-status-modal.png`)
- 🔴 **Declarations CREATE BỊ VỠ (bug production)** — field Upload bắt buộc luôn fail server (`The data.upload_id... failed to upload` — Livewire temp upload hỏng). KHÔNG tạo nổi declaration. (evidence: `t2-declaration-upload-error.png`)
- 🔴 **Enforcement compliance: KHÔNG thấy** ở UI — compliance là nhãn thủ công, chưa thấy cơ chế chặn gán việc cho candidate non-compliant.

> **Kết luận:** evidence/compliance **build nhiều hơn ta tưởng** (capture ID/video/contract thật), nhưng **engine rules + enforcement chưa có** và **Declarations đang lỗi** trên production.

---

## Finding 4 — Advert lifecycle: chỉ là enum free-select, KHÔNG state machine

- 6 status: Pending Approval / Approval Rejected / Approved / Pending Allocation / Filled / Not Filled.
- ✅/🔴 **"Update status" cho chọn cả 6 status BẤT KỂ trạng thái hiện tại** — nhảy tự do, không guard thứ tự, không điều kiện (đổi "Filled" không cần application). Status còn set được ngay ở form Create. (evidence: `t3-status-options.png`, `t3-create-status-options.png`)
- 🔴 **KHÔNG có approval workflow** thực thi (các tên Pending/Approved chỉ là nhãn, không gate).
- 🔴 **KHÔNG có side-effect** nghiệp vụ khi đổi status (modal chỉ 1 field Select).

> **Kết luận:** advert lifecycle = **model + free-select enum**, đúng mức thấp nhất. State machine/approval/guard là build mới.

---

## Finding 6 — Domain recon: KHÔNG có front-end brand/candidate live

Soi 3 subdomain (read-only, không đăng nhập):

| Subdomain | Thực chất | Bằng chứng |
|---|---|---|
| `tidalagency.co.uk` | **Marketing site** (nav: Home/How It Works/About/Contact/Agency) — KHÔNG login/register | nội dung brochure trong iframe; (evidence: `evidences/blackbox/t5-marketing-site-home.png`) |
| `app.tidalagency.co.uk` | **nginx 403 rỗng — chưa deploy app** | `HTTP 403`, body chỉ "403 Forbidden / nginx", không cookie framework; `/login` `/api` `/register` đều 404 |
| `admin.tidalagency.co.uk` | **App thật duy nhất** (Laravel/Filament) | `HTTP 200` + cookie `tidal_agency_session` + `XSRF-TOKEN` |

> **Kết luận:** brand/candidate **không có front-end live ở bất kỳ đâu**. `app.` mới là subdomain đặt sẵn, rỗng. → Data evidence ở Finding 3 gần như chắc chắn là **dev seed** (mọi candidate `@ne6.studio` = dev agency). **P2/P3 portal là greenfield**, không được giảm scope.
> **Còn mở:** marketing quảng cáo "OnDemand App" nhưng không tìm thấy bản live/app-store → cần hỏi khách có **mobile app** (iOS/Android) chưa phát hành không.

## Finding 5 — [SỬA LẠI finding cũ] Users KHÔNG có RBAC

⚠️ **Đính chính:** trước đó mình báo Users có "role selector (listbox)" = 🟡 — **SAI**. Black-box xác nhận form Create/Edit user **KHÔNG có field role/permission**, chỉ có Title (Mr/Mrs...) + Email + First/Last name + Password. Cái mình nhầm là dropdown **Title** (danh xưng), không phải role. (evidence: `t4-user-roles.png`, `t4-users-list.png`)
- Cột "Type" (hiển thị "Admin") là **giá trị derived** → gợi ý model identity **đa hình / tách bảng** (applicant / advertiser / admin riêng).

> **Tác động:** RBAC admin là **🔴 missing** (không phải 🟡). Và mô hình identity nhiều khả năng là polymorphic/separate-tables — ảnh hưởng thiết kế multi-guard auth (P1).

---

## Tổng hợp tác động tới gap analysis

| Phase | Finding cũ | Sau black-box | Hướng |
|---|---|---|---|
| P1 Auth | 🟡 "role selector tồn tại" | 🔴 KHÔNG có RBAC; identity có thể polymorphic | **tăng nhẹ** (sửa sai) |
| P5 Core loop | 🟡 Application "bare scaffold" | Application CRUD + aggregation **chạy thật**; thiếu Booking + downstream | **giảm nhẹ** phần application; Booking vẫn build mới |
| P6 Compliance | 🟡 status fields, config rỗng | Evidence capture **thật** (ID/video/contract); Required Evidence CRUD chạy; Declarations **vỡ**; enforcement chưa có | **giảm** phần capture, **+bug fix** Declarations |
| P3 Candidate portal | 🔴 "không tồn tại" | **Xác nhận KHÔNG có front-end live** (Finding 6); data evidence = dev seed | **greenfield, KHÔNG giảm** |
| P4 Adverts | 🟡 manual status | Xác nhận free-select, không state machine | giữ nguyên |
| P8 Billing | 🟡 config, 0 doc | Generation **xác nhận vắng mặt tuyệt đối** ở UI | giữ nguyên (chắc chắn hơn) |

**Net:** band ước tính (~660 MVP / ~870 full md) **vẫn hợp lý** — chỗ giảm (application logic CRUD chạy thật) bù chỗ tăng (RBAC, fix bug Declarations, Booking entity vẫn lớn). Lưu ý: "evidence capture" KHÔNG còn là chỗ giảm — Finding 6 xác nhận không có front-end live, data là seed → P2/P3 greenfield.

---

## Việc cần làm tiếp (mở)

1. ✅ **[ĐÃ GIẢI QUYẾT] Front-end candidate/brand** — domain recon (Finding 6) xác nhận KHÔNG có front-end live; data evidence là dev seed → P2/P3 greenfield. Còn lại: hỏi khách có **mobile app** (iOS/Android) chưa phát hành không (marketing nói "OnDemand App").
2. **Source code** vẫn cần để: xác nhận mô hình identity (polymorphic?), kiểm tra Invoice/Payslip có service generation ẩn (chưa wire UI) hay chưa build, và sửa bug upload Declarations.
3. **Báo khách bug:** Declarations create lỗi upload trên production.
4. **Yedi:** vẫn chưa có URL/login.
