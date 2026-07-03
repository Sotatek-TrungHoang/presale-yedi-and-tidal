---
phase: 4
title: "Cross-Platform-Compare"
status: complete
priority: P1
effort: "0.5d"
dependencies: [2, 3]
---

# Phase 4: Cross-Platform Compare → Shared vs Tách rời

## Overview
Trả lời câu hỏi chiến lược client hỏi thẳng (docx §8): Yedi & Tidal nên là **2 sản phẩm tách rời** hay **chung backend + front-end riêng theo ngành**? Dựa trên bằng chứng so sánh chéo từ Phase 2 (Tidal) + Phase 3 (Yedi), không đoán.

## Requirements
- Functional: bảng so sánh chéo + kết luận có evidence về mức độ chung/khác của 2 build.
- Non-functional: khuyến nghị phải kèm lý do kỹ thuật + tác động chi phí/thời gian.

## Architecture
So sánh trên các trục:
- **Stack & version:** Laravel/Filament/Livewire version, PHP, theme (đã biết cùng stack).
- **Data model:** resource nào trùng, field nào trùng, enum status trùng → suy ra chung codebase hay fork.
- **System config:** cùng schema settings (charge %, contract template, references) hay khác.
- **Maturity gap:** cùng thiếu (booking/billing/portal/RBAC) hay lệch nhau.
- **Hạ tầng:** cùng server/nginx pattern, cùng agency (ne6.studio), subdomain pattern.
- **Đặc thù ngành:** khác biệt bắt buộc riêng (Yedi: DBS/safeguarding; Tidal: brand/retail experience).

Từ đó phân loại quan hệ 2 codebase: **(a) cùng 1 codebase multi-deploy**, **(b) fork từ 1 base rồi tách**, hay **(c) 2 build độc lập**.

## Related Code Files
- Create: `reports/04-cross-platform-comparison.md` (bảng + kết luận + khuyến nghị kiến trúc).
- Read: `reports/02-*`, `reports/03-*`.

## Implementation Steps
1. Lập bảng `Trục | Yedi | Tidal | Giống/Khác` cho stack, resource list, field chính, status enum, system settings.
2. Fingerprint version: so header/asset/Filament build của 2 site (read-only) để suy ra chung base hay không.
3. Phân loại quan hệ codebase (a/b/c) với bằng chứng.
4. Đánh giá 3 kịch bản kiến trúc tương lai + trade-off:
   - **Shared backend, multi-tenant, front-end riêng ngành** (bản năng client).
   - **Shared core library + 2 deploy riêng.**
   - **2 sản phẩm hoàn toàn tách rời.**
   Mỗi kịch bản: chi phí, tốc độ, rủi ro compliance-tách-biệt (safeguarding của Yedi không lẫn beauty của Tidal), khả năng tái dùng công build.
5. Ra **khuyến nghị 1 dòng** + lý do, kèm ước lượng tác động lên effort/cost (feed Phase 6).

## Success Criteria
- [ ] Bảng so sánh chéo hoàn chỉnh, có bằng chứng.
- [ ] Kết luận rõ 2 build hiện tại đang chung/fork/độc lập.
- [ ] Khuyến nghị kiến trúc tương lai (shared vs tách) có trade-off + tác động chi phí.

<!-- Updated: Validation Session 1 - two-step: black-box now + đánh dấu chỗ cần source; xin source read-only ở bước sau nếu cần chốt chắc -->

## Risk Assessment
- **Rủi ro:** không có source code → không chắc 100% chung codebase → kết luận dựa trên bằng chứng black-box + fingerprint, ghi rõ mức độ chắc chắn (confidence). **Two-step:** ra kết luận black-box trước + đánh dấu rõ điểm nào cần source để xác nhận; nếu cần chốt chắc thì xin source/DB read-only ở bước sau (không block phase này).
- **Rủi ro:** khuyến nghị lệch mong đợi client → trình bày trade-off khách quan, để client quyết, không áp đặt.
