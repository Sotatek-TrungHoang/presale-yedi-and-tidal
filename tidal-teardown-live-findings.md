# Bóc tách trực tiếp — Tidal Agency Admin (live teardown)

> Đăng nhập & khảo sát thực tế `https://admin.tidalagency.co.uk/admin/` bằng agent-browser.
> Ngày: 2026-06-29 · Credential do khách cung cấp (steven.gibbons@ne6.studio).
> Mục đích: xác thực độ hoàn thiện thực tế để siết lại báo giá.

## Tóm tắt 1 dòng

Phần **xương sống** (data model + admin CRUD cho Advert/Candidate/Brand + dashboard) **đã có thật và tái sử dụng được**. Phần **cơ bắp** — lõi giao dịch (applications → booking → invoice → payslip) và engine compliance — **mới chỉ là scaffold CRUD rỗng, chưa cài logic nghiệp vụ** → về cơ bản là build mới, không phải "extend".

---

## Nền tảng kỹ thuật (xác nhận)

- **Laravel + Filament** admin panel (đúng như phân tích ban đầu). Login chạy ổn.
- Một deployment cho Tidal. Sidebar: Dashboard, Brands, Adverts, Candidates, Applications, Invoices, Payslips, Settings (Declarations, Job Roles, Required Evidence, Types Of Work, System), Admin (Users).
- Route slug khác tên hiển thị: Brands=`/advertisers`, Candidates=`/applicants`.

---

## Phần ĐÃ có (tái sử dụng được)

### Dashboard — `evidences/01-dashboard.png`
Widget thống kê + **tài chính**: Brands 2, Candidates 9, Adverts 1, Total Income / Expenditure / Brand Charges / Candidate Charges / Total Profit (tất cả £0.00). → khung báo cáo doanh thu đã có.

### Adverts — `evidences/04-adverts-list.png`, `evidences/02-advert-detail.png`
Model **giàu**, form create/edit đầy đủ:
- Title, Brand, Type (Day to day / Long term), Status (Approved/Filled/Not filled/Pending allocation/Pending approval/Rejected).
- Address đầy đủ (Line 1/2, Town, Postcode, Country).
- Date range (Starts/Ends), Shift (Start/End time), Apply-by.
- Description rich-text (mô tả dài thật của House of Creed).
- Repeater **Documents**.
- **Payment & Charges**: Brand Pay Rate £150 / Daily, Brand Charge 15%, Candidate Charge 5%.
- Tab filter theo status + bulk actions + toggle columns (chuẩn Filament).
- Data: 1 advert (Kering — Luxury Brand Ambassador, Bicester Village, Not Filled).

### Candidates — `evidences/05-candidates-list.png`, `evidences/03-candidate-detail.png`
Model **sâu nhất**:
- Detail 4 tab: **Personal / Identification / Work / Contracts**.
- Action **Update status** + **Update references**.
- Personal: title, tên, email, phone, DOB, address; Details: Status (Active/Incomplete/Pending), Compliance (Compliant/Non-compliant), Job Role, Type of work, Qualification, Rating.
- Data: 9 candidate, đa số **Incomplete / Pending Approval**; 2 Active/Compliant (đều là record test).

### Brands — `evidences/06-brands-list.png`
Model nhẹ hơn: Status, Compliance (Pending/Compliant/Non-compliant), Name, Email, Telephone, Date Joined. Data: 2 (Creed, Kering — đều Incomplete/Pending).

---

## Phần CHƯA có (điểm then chốt cho báo giá)

| Module | Bằng chứng | Thực tế |
|---|---|---|
| **Applications** | `evidences/07-applications-empty.png` | **TRỐNG** — 9 candidate + 1 advert nhưng **0 application**. Luồng matching → booking chưa từng chạy với data thật → nhiều khả năng chưa hoàn thiện/chưa test. |
| **Invoices** | `evidences/08-invoices-empty.png` | **TRỐNG**, không có nút "New" → thiết kế để auto-generate; engine sinh hóa đơn chưa có. |
| **Payslips** | `evidences/09-payslips-empty.png` | **TRỐNG**, không có nút "New" → tương tự. |
| **Required Evidence** | `evidences/10-required-evidence-empty.png` | **TRỐNG** → quy tắc compliance (giấy tờ cần nộp / right-to-work) **chưa cấu hình**. |
| **Declarations** | `evidences/11-declarations-empty.png` | **TRỐNG** → cam kết/khai báo chưa cấu hình. |
| **Job Roles** | (khảo sát text) | chỉ có **"Any Role"** → gần như chưa cấu hình. |
| **Types of Work** | (khảo sát text) | 3 mục (Short/Long term temporary, Permanent) — đã config. |

**Diễn giải:** các module trống **không phải "xây xong nhưng chưa dùng"** mà là **Filament resource rỗng chưa cài business logic**. Toàn bộ lõi giao dịch (matching → booking lifecycle → invoice → payslip generation) và engine compliance là **greenfield**.

---

## Yedi (chưa verify được)

- Khách nói "cùng platform, khác thị trường" nhưng mới gửi credential **Tidal**; **chưa có URL/login Yedi**.
- Thử đoán `admin.yediagency.co.uk`, `admin.yedi.co.uk` → không resolve. `yedi.agency` chỉ là site WordPress marketing.
- → Cần khách gửi URL + login Yedi nếu muốn verify riêng (giả định hiện tại: cùng codebase, deploy/config riêng).

---

## Ảnh hưởng tới ước tính

- Giả định **"Keep & extend" đúng cho data model + admin CRUD** → tái sử dụng tốt.
- **SAI cho business logic lõi** → phần lõi giao dịch + compliance phải build mới → **đẩy effort backend lên**.
- Ước tính bottom-up theo từng feature: xem `plans/260629-feature-gap-analysis/` (gap analysis) và `tidal-yedi-uoc-tinh-tu-gap-analysis.md` (ước tính VN). MVP ~660 md; full production-grade ~870 md.

## Độ tin cậy & rủi ro còn lại

- ✅ Đã xác thực **độ hoàn thiện UI/flow** (chắc chắn hơn nhiều so với chỉ đọc mô tả).
- ❌ **Vẫn chưa thấy source code** → chất lượng code (sạch/rối) là biến số còn lại ±15–20%.
- → **Audit code (2 tuần đầu)** vẫn cần làm trước khi chốt fixed-price.

## Câu hỏi chưa giải quyết

1. URL + login Yedi để verify deployment thứ hai?
2. Quyền Git source code để audit chất lượng code (biến số lớn nhất còn lại)?
3. Các module trống (Applications/Invoice/Payslip) trong code đã có controller/logic phần nào chưa, hay mới chỉ là Filament resource rỗng? (chỉ trả lời được khi có source).
