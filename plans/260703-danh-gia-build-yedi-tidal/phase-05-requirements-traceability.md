---
phase: 5
title: "Requirements-Traceability"
status: complete
priority: P1
effort: "0.5d"
dependencies: [2, 3]
---

# Phase 5: Requirements Traceability (map vào Tidal.docx)

## Overview
Đối chiếu **từng yêu cầu client trong `Tidal.docx`** với hiện trạng thực tế đã verify (Phase 2 Tidal + Phase 3 Yedi). Kết quả là 1 ma trận traceability: mỗi capability → trạng thái ✅/🟡/🔴 riêng cho Yedi và Tidal, kèm evidence ref. Đây là bằng chứng "cái gì có/thiếu" để client thấy rõ, không nói chung chung.

## Requirements
- Functional: mọi requirement docx §2–§6 đều có 1 dòng trạng thái/platform + ghi chú.
- Non-functional: mỗi trạng thái link tới evidence (report/ảnh) — không tự nhận.

## Architecture
Ma trận dựng từ checklist Phase 1, cột hoá theo docx:
- **§2 Candidate/Worker side** (đăng ký, profile live record, upload doc, availability, apply/accept, timesheet, payment status, notification, feedback, referral).
- **§2 Client/School side** (đăng ký, submit request, xem matched candidate, approve booking, attendance, approve timesheet, feedback, invoice/report).
- **§2 Admin side** (duyệt candidate, verify doc, compliance, booking, assign, override matching, timesheet, notification, cancellation/no-show, feedback, report/export, manage region/role/rate).
- **§3 Yedi-specific** (DBS, safeguarding, references, qualifications, RTW, school booking, matching logic giáo dục).
- **§4 Tidal-specific** (brand/retail/fragrance experience, talent pool by city/brand, client visibility, matching logic beauty).
- **§5 Workflows** (registration, client booking, timesheet, compliance, feedback) — mỗi workflow chạy được tới đâu.
- **§6 MVP list** — riêng cột đánh dấu cái nào đã có, để tính "khoảng cách tới MVP".

## Related Code Files
- Create: `reports/05-requirements-traceability-matrix.md` (ma trận đầy đủ, 2 cột Yedi/Tidal).
- Read: checklist Phase 1, `reports/02-*`, `reports/03-*`.

## Implementation Steps
1. Lấy checklist Phase 1, điền trạng thái từng dòng cho **Tidal** (từ Phase 2 + prior findings).
2. Điền trạng thái từng dòng cho **Yedi** (từ Phase 3).
3. Gắn evidence ref (report/ảnh) cho mỗi ô 🟡/✅; ô 🔴 ghi "không tìm thấy đường nào" (bằng chứng vắng mặt).
4. Tô riêng nhóm **§6 MVP** → đếm % MVP đã có / còn thiếu cho mỗi platform.
5. Highlight các workflow §5 đứt gãy ở đâu (vd booking chain dừng sau Application).
6. Tổng hợp "top gap" chung 2 platform vs gap riêng từng platform → feed Phase 6.

## Success Criteria
- [ ] Ma trận traceability phủ hết requirement docx §2–§6, đủ 2 cột Yedi/Tidal.
- [ ] Mỗi ô có trạng thái + evidence ref (hoặc ghi chú vắng mặt).
- [ ] Có % hoàn thành MVP (§6) cho mỗi platform.
- [ ] Danh sách gap chung vs gap riêng đã tách rõ.

## Risk Assessment
- **Rủi ro:** requirement docx mơ hồ, khó map 1-1 → giữ nguyên văn requirement, ghi diễn giải khi cần, không bịa capability.
- **Rủi ro:** trạng thái dựa trên black-box (không source) → đánh dấu confidence, phân biệt "verified vắng mặt" vs "chưa kiểm được".
