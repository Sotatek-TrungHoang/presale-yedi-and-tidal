# Phase 3 — Yedi: Bóc tách live + black-box (đánh giá lần đầu)

> Đăng nhập & khảo sát trực tiếp `https://admin.yedi.group/admin` bằng browser automation (Playwright).
> Ngày: 2026-07-03 · Account: admin Yedi (credential ở `client/credentials.txt`, gitignored).
> Đây là **lần đầu Yedi được đánh giá** (trước 29/06 chưa có login).
> Evidence: accessibility snapshot + field-extraction JS (richer than pixels) + screenshot dashboard.
> Lưu ý: browser chạy trong container → ảnh PNG không ghi được vào repo local; bằng chứng chính là snapshot cấu trúc trích trực tiếp từ DOM live.

## Tóm tắt 1 dòng

**Yedi = ĐÚNG codebase Tidal, deploy riêng, đổi nhãn hiển thị (Teacher/School/Job) + cấu hình per-tenant.** Không có engine compliance giáo dục (DBS/safeguarding) thực — chỉ là model staffing generic của Tidal gắn nhãn giáo dục. Lõi giao dịch (application→booking→invoice) và billing **trống y hệt Tidal**. Yedi thực chất **kém hoàn thiện hơn Tidal về dữ liệu** (0 job, 0 application vs Tidal 1 advert).

---

## 1. Bằng chứng "cùng codebase với Tidal" (quan trọng nhất cho Phase 4)

| Bằng chứng | Chi tiết |
|---|---|
| **Route slug trùng khít** | Nav hiển thị Schools/Jobs/Teachers nhưng URL là `/advertisers`, `/adverts`, `/applicants` — **y hệt Tidal**. Slug generic (advertiser/applicant) = code gốc build cho Tidal, Yedi chỉ override label. |
| **Toàn bộ resource trùng** | Dashboard, `/advertisers`, `/adverts`, `/applicants`, `/applications`, `/invoices`, `/payslips`, `/declarations`, `/job-roles`, `/required-evidences`, `/type-of-works`, `/system`, `/users` — danh sách y hệt Tidal. |
| **Field label generic lộ ra ở System** | Trang System settings ghi **"Default applicant charge percentage"** + **"Default advertiser charge percentage"** (tên gốc Tidal) dù UI ngoài đã đổi thành Teacher/School → form config KHÔNG được relabel, chạy trên base code Tidal. |
| **Teacher detail = Candidate detail Tidal** | 4 tab y hệt: Personal / Identification / Work / Contracts; action y hệt: Update status / Update references. |
| **Dashboard widget y hệt** | Schools/Teachers/Jobs + Total Income/Expenditure/School Charges/Teacher Charges/Total Profit (Tidal: Brand/Candidate Charges). Chỉ đổi từ ngữ. |
| **Seed data cùng agency** | Mọi record là seed `matthew.woodley+*@ne6.studio` (Apple Test School, Google Tester, John Smith, Google Teacher) — **cùng dev agency ne6.studio như Tidal**. |
| **Session cookie riêng** | `yedi_education_session` vs `tidal_agency_session` → **deploy tách biệt, DB riêng** (KHÔNG phải multi-tenant chung 1 instance). |

**Kết luận quan hệ codebase:** **(b) fork/deploy riêng từ 1 base chung** — cùng source, 2 deployment độc lập, cấu hình + nhãn khác nhau. KHÔNG phải (a) multi-tenant 1 instance, KHÔNG phải (c) 2 build độc lập. (Chi tiết trade-off ở Phase 4.)

---

## 2. Inventory resource + maturity

Legend: ✅ done · 🟡 partial · 🔴 missing.

| Resource (nav / slug) | Data live | Maturity | Ghi chú |
|---|---|:---:|---|
| Dashboard | 2 schools / 19 teachers / 0 jobs / £0 | ✅ | Widget count + tài chính; tất cả £0 (chưa transact). Có widget "Non-compliant Teachers"=0. |
| Schools `/advertisers` | 2 (seed) | ✅ CRUD | Status/Compliance/Name/Jobs/Email/Tel/DateJoined — = Brands Tidal. |
| Teachers `/applicants` | 19 (đa số Incomplete, vài Active seed) | ✅ CRUD | = Candidate model Tidal (xem §3). |
| Jobs `/adverts` | **0** | 🟡 model | Form giàu = advert Tidal; enum 6 status y hệt; **chưa có job nào**. |
| Applications `/applications` | **0** | 🟡 scaffold | Có "New application"; chưa chạy với data thật. |
| Invoices `/invoices` | **0** | 🔴 | Chỉ "Toggle columns" — **KHÔNG nút New/Generate**. |
| Payslips `/payslips` | **0** | 🔴 | Tương tự — không generate. |
| Declarations `/declarations` | 0 | 🔴/bug | Form Title/Description/Time/Upload* = form Tidal (Tidal bug upload Livewire); cần repro để chốt. |
| Job Roles `/job-roles` | **5** (giáo dục) | ✅ config | Primary/Secondary/SEN Teacher QTS, Nursery Nurse Qualified/Unqualified — **richer hơn Tidal ("Any Role")**. |
| Required Evidence `/required-evidences` | **1** ("DBS Evidence") | 🟡 config | 1 dòng catalog thu thập DBS — **KHÔNG phải engine track DBS number/expiry**. Tidal: trống. |
| Types Of Work `/type-of-works` | (chưa mở chi tiết) | ✅ config | Giả định = Tidal (short/long/permanent). |
| System `/system` | configured | ✅ | Charge %, references required, invoice bank/terms, Applicant/Advertiser contract templates — schema = Tidal. |
| Users `/users` | admin | 🔴 RBAC | Form chỉ Title/Email/Name/Password — **KHÔNG field role/permission** (= Tidal, no RBAC). |

---

## 3. Teacher (Candidate) model — chi tiết

**4 tab = Tidal Candidate:**
- **Personal:** Title, First/Last name, Email, Telephone, DOB, Address, Status (Active/Incomplete/Pending), Compliance (Compliant/Non-compliant/Incomplete/Pending Approval), Job Role, Type of work, **Qualification** (vd "Masters"), **Rating** (vd 4.5), **Teacher number**.
- **Identification:** Photograph, Evidence of ID, Video verification — **y hệt Tidal, không field DBS/safeguarding riêng**.
- **Work:** References (Name/Tel/Email/Status "Sent to Referee"), **Right to work uk**, **Require visa to work uk**, **Lived or worked outside uk 6 months**, **Has criminal convictions or prosecutions pending**, Declaration agreements, Applicant evidence, Applications (+ New application).
- **Contracts:** "Yedi Employment Contract Feb 12" (= Tidal "Tidal Employment Contract Feb 17"), Upload/Link.

**Lớp compliance giáo dục — kết luận:**
- **CÓ (generic, chung với Tidal):** self-declaration RTW / visa / lived-outside-UK / criminal-convictions; References workflow; Compliance status label (thủ công); Evidence upload (photo/ID/video); 1 catalog "DBS Evidence".
- **KHÔNG CÓ (client cần cho giáo dục — docx §3):** DBS **number + ngày hết hạn/gia hạn** dạng field có track; safeguarding training record; QTS/qualification structured (chỉ 1 field text "Qualification" + role name có chữ "QTS"); **document expiry flagging**; **enforcement gate** chặn book teacher non-compliant/DBS hết hạn.
- → Compliance giáo dục Yedi = **nhãn thủ công + thu thập giấy tờ**, KHÔNG phải engine. Đây là gap lớn nhất riêng của Yedi vì liên quan safeguarding trẻ em.

---

## 4. Black-box behavioral (live-verified 2026-07-03)

| Hành vi | Kết quả | Cách verify |
|---|---|---|
| **Billing generation** | 🔴 **Vắng mặt** — Invoices & Payslips chỉ có "Toggle columns", không New/Generate ở bất kỳ đâu | live-verified (đọc toàn bộ action toolbar) |
| **RBAC** | 🔴 Không — form user không có role/permission | live-verified (create form) |
| **Lõi giao dịch** | 🔴 Chưa chạy — 0 job, 0 application, dashboard £0 | live-verified |
| **Declarations create** | Form = Tidal (Upload* required); Tidal vỡ do Livewire temp-upload | form live-verified; **repro upload chưa chạy** (cần dummy file trong container) → confidence trung bình, chốt bằng source (two-step) |
| **Booking chain** (Application Accepted → Booking? auto status? auto invoice?) | **Suy ra từ same-codebase** — Tidal đã black-box: Application CRUD+aggregation chạy, KHÔNG Booking entity, KHÔNG auto invoice. Yedi cùng code → hành vi trùng | **inferred (confidence cao)**; test write định danh chạy trên Tidal (Phase 2) để tránh ghi thừa lên Yedi |

**Ghi chú test-write:** đã tạo form Declaration `ZZTEST_` nhưng **KHÔNG submit** (không persist record nào); baseline Yedi nguyên vẹn (Declarations vẫn 0). Không record test nào tồn tại trên Yedi sau audit.

---

## 5. Domain / portal
- `admin.yedi.group` = app Filament duy nhất chạy (200).
- `app.yedi.group` = **403 placeholder** (không portal educator/school live) — verify curl.
- `yedi.group` = 200 (marketing).
- → **Không có front-end educator/school live** — y hệt tình trạng Tidal. Portal là greenfield cho cả 2.

---

## 6. Khác biệt Yedi vs Tidal (tóm tắt, feed Phase 4)
| Trục | Yedi | Tidal |
|---|---|---|
| Codebase | **Chung** (cùng base Laravel/Filament) | **Chung** |
| Deploy | Riêng (`yedi_education_session`, DB riêng) | Riêng (`tidal_agency_session`) |
| Nhãn | School/Teacher/Job | Brand/Candidate/Advert |
| Job Roles config | 5 (giáo dục, có QTS) | 1 ("Any Role") |
| Required Evidence | 1 ("DBS Evidence") | 0 |
| Data live | 2 school / 19 teacher / **0 job / 0 app** | 2 brand / 9 cand / **1 advert / 0 app** |
| Compliance giáo dục thực (DBS engine/safeguarding) | 🔴 không (chỉ nhãn + 1 catalog DBS) | N/A |
| Billing / RBAC / portal / booking entity | 🔴 thiếu (= Tidal) | 🔴 thiếu |

**Net:** Yedi KHÔNG "đi trước" Tidal ở mảng giáo dục — cùng bộ khung, chỉ config nhãn + vài job-role/DBS-catalog. Toàn bộ engine (booking, billing, compliance enforcement, portal, RBAC) đều thiếu như Tidal.
</content>
