---
phase: 6
title: "Consolidated-Deliverables"
status: complete
priority: P1
effort: "1d"
dependencies: [4, 5]
---

<!-- Updated: Validation Session 1 - deliverable VN phục vụ NỘI BỘ Sotatek; bản EN client-facing ngoài scope; tái dùng bản dịch vi/ sẵn có trong git; two-step nguồn dữ liệu -->

# Phase 6: Consolidated Deliverables (bộ nội bộ Sotatek — tiếng Việt)

## Overview
Tổng hợp toàn bộ finding thành bộ deliverable theo khung `Tidal.docx` §8. Đây là output cuối của plan, **phục vụ nội bộ team presale Sotatek** (không phải bản gửi thẳng client). Tái dùng estimate/effort/proposal cũ (recover từ git) làm baseline, cập nhật theo finding Yedi + cross-platform mới. **Tất cả tiếng Việt.** Bản English client-facing (nếu client UK cần) là việc TÁCH RIÊNG, ngoài scope plan này.
**Lưu ý tái dùng:** gap analysis cũ đã có sẵn bản dịch `vi/` trong commit `07c6c5f` → tái dùng, không dịch lại từ đầu.

## Requirements
- Functional: 6 deliverable §8 đầy đủ, dựa trên bằng chứng Phase 2–5.
- Non-functional: ngắn gọn, thẳng thắn, ưu tiên bảng; số liệu effort/cost có cơ sở (từ gap → man-day).

## Architecture
Bộ deliverable (map thẳng docx §8):
1. **Đánh giá hiện trạng** — mỗi platform: dùng được / cần fix / cần rebuild (bảng maturity từ Phase 2/3/5).
2. **Rủi ro kỹ thuật** — bug production (vd Declarations upload), thiếu RBAC, thiếu enforcement compliance (nặng với Yedi safeguarding), không portal, không test/CI, PII/GDPR.
3. **Route nhanh nhất tới MVP ổn định** — dựa §6 MVP list + gap, xếp theo dependency (auth → portal → booking chain → timesheet → billing → compliance enforcement).
4. **Product roadmap** — MVP / Phase 2 / Future, tách phần chung 2 platform vs phần riêng ngành.
5. **Ước tính thời gian & chi phí** — man-day theo feature (tái dùng `tidal-yedi-effort-breakdown` + bổ sung Yedi delta), quy ra timeline + GBP/USD. Số dựa black-box → gắn range + confidence + điều kiện "cần source để chốt" (two-step, khớp Phase 4).
6. **Khuyến nghị kiến trúc** — shared vs tách rời (kết luận Phase 4), kèm tác động chi phí.

## Related Code Files
- Create: `reports/06-danh-gia-hien-trang-va-rui-ro.md` (§8.1 + §8.2).
- Create: `reports/06-route-mvp-va-roadmap.md` (§8.3 + §8.4).
- Create: `reports/06-uoc-tinh-thoi-gian-chi-phi.md` (§8.5).
- Create: `reports/06-khuyen-nghi-kien-truc.md` (§8.6, tóm từ Phase 4).
- Create: `reports/06-assessment-noibo-tieng-viet.md` (bản gộp nội bộ Sotatek — executive summary + 6 mục §8).
- Create: `reports/07-traceability-reconciliation-gate.md` (gate map matrix↔roadmap/proposal — chống rớt feature).
- Read: `reports/prior-tidal/tidal-yedi-*` (estimate/effort/proposal cũ), `reports/04-*`, `reports/05-*`.

## Implementation Steps
1. **Hiện trạng + rủi ro:** từ ma trận Phase 5, viết bảng "dùng được/fix/rebuild" cho từng platform; liệt kê rủi ro kỹ thuật xếp theo mức nghiêm trọng.
2. **MVP route:** từ §6 MVP list và gap, dựng đường đi ngắn nhất tới MVP ổn định (thứ tự có dependency), nêu rõ cái gì tái dùng được (spine data model) vs build mới.
3. **Roadmap:** MVP → Phase 2 → Future; đánh dấu hạng mục chung (làm 1 lần cho cả 2) vs riêng ngành.
4. **Effort + cost:** lấy effort breakdown Tidal cũ làm baseline, cộng Yedi delta (đa số chung nếu shared backend — số từ Phase 4), quy ra man-day → timeline → chi phí GBP/USD. Ghi rõ giả định.
5. **Khuyến nghị kiến trúc:** chốt 1 khuyến nghị từ Phase 4, gắn tác động chi phí (shared tiết kiệm bao nhiêu %).
6. **Gộp bản assessment nội bộ tiếng Việt:** executive summary + 6 mục, format bảng, thẳng thắn. Kèm phần "giả định & phụ thuộc cần xác nhận" (vd cần source code để chốt vài con số).
7. **Whole-plan consistency check:** rà lại toàn bộ report, đảm bảo maturity/số liệu nhất quán giữa các file.
8. **Traceability reconciliation gate (BẮT BUỘC trước khi phát hành proposal):** chạy `reports/07-traceability-reconciliation-gate.md` — map MỌI ID trong ma trận Phase 5 tới đúng 1 đích (MVP/T2/Future/Reuse/Out). ID nào không map được, hoặc 🔴/🟡 mà bị coi là Reuse = FLAG, phải xử lý trước khi chốt. Cross-check ngược: mọi item MVP/T2 phải truy được (gọi tên hoặc gộp rõ) trong proposal .docx. Bước này chặn lỗi "nén lossy" làm rớt feature khỏi proposal (đã xảy ra draft v1: Referral/Training/Ratings/Availability-naming).

## Success Criteria
- [ ] Đủ 6 deliverable §8, tiếng Việt, dựa trên evidence Phase 2–5.
- [ ] Effort/cost có breakdown theo feature + giả định rõ ràng, không phải số trên trời.
- [ ] Khuyến nghị shared-vs-tách có kết luận dứt khoát + trade-off.
- [ ] Bản assessment nội bộ Sotatek gộp sẵn sàng để team presale review.
- [ ] Không mâu thuẫn số liệu giữa các report.
- [ ] Reconciliation gate PASS: mọi ID matrix Phase 5 map được, không còn FLAG; mọi item MVP/T2 truy được trong proposal.

## Risk Assessment
- **Rủi ro:** ước tính thiếu chính xác do không có source → gắn dải (range) + confidence + điều kiện "cần source để chốt", không đưa 1 con số cứng.
- **Rủi ro:** client kỳ vọng MVP rẻ/nhanh hơn thực tế → trình bày trade-off scope↔cost↔time minh bạch, đề xuất commercial model audit-first (như proposal cũ) để de-risk.
- **Rủi ro:** lẫn số liệu cũ (chỉ Tidal) với phạm vi mới (2 platform) → tách rõ baseline vs delta trong file effort.
