---
phase: 3
title: "Yedi-Live-Eval"
status: complete
priority: P1
effort: "1.5d"
dependencies: [1]
---

# Phase 3: Yedi Live Evaluation (phần mới lớn nhất)

## Overview
Đánh giá **Yedi lần đầu tiên** (trước đây không có login). Áp dụng đúng phương pháp đã dùng cho Tidal: teardown resource + form + system config, rồi black-box behavioral test các flow chính. Chú trọng đặc thù giáo dục: DBS, safeguarding, references, qualifications, right-to-work — vốn là lớp compliance nặng hơn Tidal (docx §3).

<!-- Updated: Validation Session 1 - client ủy quyền free test (ghi/xóa) trên production, ràng buộc cleanup sạch; full behavioral test kể cả luồng compliance/safeguarding -->

## Requirements
- Functional: dựng bản đồ hiện trạng Yedi đầy đủ theo cùng khung 14 domain như Tidal, có maturity + evidence.
- Non-functional: black-box được **ghi/xóa** production (client ủy quyền free test) — bắt buộc cleanup sạch + verify baseline; không đụng/không export PII candidate/school thật.

## Architecture
Yedi = Laravel + Filament (đã fingerprint). Kỳ vọng cấu trúc tương tự Tidal nhưng thuật ngữ giáo dục (School thay Brand, Educator/Teacher thay beauty candidate, DBS/safeguarding thay beauty compliance). **Phải verify chứ không giả định** — điểm mấu chốt cho Phase 4.

Domain cần soi (khớp 14 domain gap analysis Tidal để so sánh được):
Identity/Auth · School(Client) model · Educator(Candidate) model · Advert/Job lifecycle · Applications/Matching/Booking · Compliance (DBS/safeguarding/RTW/references/qualifications) · Timesheets · Billing (invoices/payslips) · Payments · Notifications · Documents/Contracts/e-sign · Multi-tenancy · Reporting · Non-functional/security.

## Related Code Files
- Create: `reports/03-yedi-teardown-live-findings.md` (resource/form/config inventory).
- Create: `reports/03-yedi-blackbox-test-findings.md` (bằng chứng hành vi các flow).
- Evidence: `evidences/yedi/*.png`.

## Implementation Steps
1. **Login + Dashboard** `admin.yedi.group/admin` — chụp toàn cảnh menu, số liệu, widget.
2. **Resource inventory:** liệt kê mọi resource ở sidebar; mở list từng cái (School/Educator/Advert/Application/Compliance/Invoice/Payslip/Declaration/Required-Evidence/User…).
3. **Form teardown:** mở form Create + Edit từng resource → ghi field, quan hệ, enum status, modal/slide-over actions. Đặc biệt soi field compliance giáo dục: **DBS number/status/expiry, safeguarding training, right-to-work, references, qualifications, employment history**.
4. **System settings:** charge %, references-required, invoice bank/terms, contract templates (giống Tidal?), cấu hình school/region/role/rate.
5. **Black-box flow (theo protocol Phase 1):**
   - Registration/approve educator (nếu có trong admin).
   - Booking chain: tạo Application Accepted → quan sát có Booking entity? advert status auto-change? dashboard đổi?
   - Billing: có nút Generate invoice/payslip ở đâu không? (kiểm tra tuyệt đối như Tidal Finding 2).
   - Compliance enforcement: có chặn gán việc cho educator non-compliant / DBS hết hạn không? có flag document expiry không?
   - Declarations create: có dính cùng bug Livewire upload như Tidal không?
6. **Domain recon:** `yedi.group` (marketing?), `app.yedi.group` (đã biết 403). Xác nhận không có portal educator/school live.
7. **Cleanup** mọi record test, verify baseline, chụp ảnh.

## Success Criteria
- [ ] `03-yedi-teardown-live-findings.md`: inventory đầy đủ resource + form + system config Yedi, mỗi domain có maturity ✅/🟡/🔴.
- [ ] `03-yedi-blackbox-test-findings.md`: bằng chứng hành vi cho booking chain, billing generation, compliance enforcement, declarations.
- [ ] Kết luận rõ về lớp compliance giáo dục (DBS/safeguarding): có engine thật hay chỉ nhãn thủ công.
- [ ] Xác nhận có/không portal educator-school live.
- [ ] Production Yedi về baseline; evidence lưu `evidences/yedi/`.

## Risk Assessment
- **Rủi ro:** Yedi có PII học sinh/giáo viên/safeguarding (nhạy cảm cao) → tuyệt đối không export, không chụp cận PII, che thông tin khi cần ảnh.
- **Rủi ro:** giả định "giống Tidal" sai → bắt buộc verify từng field, đừng copy finding Tidal sang.
- **Rủi ro:** black-box đụng dữ liệu thật do khó phân biệt record test/thật → tiền tố `ZZTEST_`, xoá ngay, verify.
