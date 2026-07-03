---
phase: 2
title: "Tidal-ReVerify"
status: complete
priority: P2
effort: "1d"
dependencies: [1]
---

<!-- Updated: Validation Session 1 - re-verify rộng toàn resource (không chỉ 6 headline finding); effort 0.5d→1d -->

# Phase 2: Tidal Re-Verify (broad pass)

## Overview
Không đánh giá lại Tidal từ đầu — Tidal đã có audit verified 2026-06-29. Phase này **re-verify rộng**: duyệt lại toàn bộ resource Tidal (không chỉ 6 headline finding) để bắt thay đổi build/data trong khoảng 29/06→03/07, lấy 6 điểm cốt lõi làm checklist tối thiểu bắt buộc. Chạy song song được với Phase 3.

## Requirements
- Functional: duyệt lại toàn bộ resource + xác nhận/điều chỉnh 6 finding cốt lõi Tidal; cập nhật maturity nếu build đã đổi.
- Non-functional: ưu tiên các điểm đã biết trước, nhưng quét đủ resource để không bỏ sót thay đổi ngoài 6 điểm.

## Architecture
Đối chiếu live vs finding cũ theo checklist 6 điểm đã verified trước đây:
1. Chuỗi giao dịch: Application CRUD + aggregation **chạy**, nhưng **không có Booking entity**, advert status **không auto-transition**, **không auto-gen invoice/payslip**.
2. Invoice/Payslip generation: **vắng mặt tuyệt đối** (không nút New/Generate ở bất kỳ resource nào).
3. Compliance: Required Evidence + References + evidence storage (ID/video/contract) **thật**; **Declarations create bị vỡ** (Livewire upload bug); **không có enforcement** chặn non-compliant.
4. Advert lifecycle: enum free-select 6 status, **không state machine/approval guard**.
5. Auth: admin login chạy; **không RBAC**; không portal auth/reset/2FA.
6. Domain: **không có front-end brand/candidate live** (`app.` = 403 placeholder); candidate evidence có thể là seed `@ne6.studio`.

## Related Code Files
- Create: `reports/02-tidal-reverify-delta.md` (chỉ ghi delta so với 2026-06-29).
- Read: `reports/prior-tidal/*` (từ Phase 1).
- Evidence: bổ sung ảnh mới nếu phát hiện thay đổi → `evidences/tidal-reverify/`.

## Implementation Steps
1. Login `admin.tidalagency.co.uk/admin`, chụp Dashboard (số advert/application/invoice/£).
2. **Duyệt toàn bộ resource sidebar** (không chỉ 6 điểm): mở list + form từng resource, đối chiếu inventory 29/06 → đánh dấu resource/field/enum nào mới, mất, hoặc đổi.
3. Với 6 điểm cốt lõi: still-true / changed / new-behavior. Chỉ black-box khi cần phân biệt logic vs data (theo protocol Phase 1).
4. Kiểm tra riêng bug Declarations create (Finding cũ) — còn vỡ không.
5. Ghi delta: điểm/resource nào còn đúng → "confirmed, no change"; điểm nào đổi → mô tả + evidence.
6. Cleanup mọi record test, verify baseline.

## Success Criteria
- [ ] Toàn bộ resource Tidal được duyệt lại; mọi thay đổi so với inventory 29/06 được ghi nhận.
- [ ] 6 headline finding Tidal được đánh dấu confirmed hoặc changed (có evidence cho changed).
- [ ] Bug Declarations create được xác nhận trạng thái hiện tại.
- [ ] `02-tidal-reverify-delta.md` hoàn tất; production về baseline.

## Risk Assessment
- **Rủi ro:** re-verify rộng tốn thời gian hơn delta pass → ưu tiên 6 điểm cốt lõi trước, quét phần còn lại ở mức inventory (list/form), chỉ black-box khi phát hiện đổi.
- **Rủi ro:** finding cũ sai lệch nhỏ → ưu tiên bằng chứng live hiện tại, ghi rõ mâu thuẫn.
