---
phase: 1
title: "Setup-Methodology"
status: complete
priority: P1
effort: "0.5d"
dependencies: []
---

# Phase 1: Setup & Methodology

## Overview
Chuẩn bị nền cho toàn bộ audit: recover asset đánh giá Tidal cũ từ git, dựng protocol black-box an toàn cho production, và trích khung requirement từ `client/Tidal.docx` để làm xương sống traceability matrix (Phase 5).

## Requirements
- Functional: có đủ context cũ + khung requirement + protocol test trước khi đụng production.
- Non-functional: an toàn PII, không rò rỉ credential, thao tác trên production đảo ngược được.

## Architecture
Không có kiến trúc code. Đây là bước setup tài sản & quy trình:
- **Nguồn cũ (git `07c6c5f`):** `tidal-teardown-live-findings.md`, `tidal-blackbox-test-findings.md`, `tidal-agency-analysis.md`, `plans/260629-feature-gap-analysis/*` (14 phase), `tidal-yedi-*` (estimate/effort/proposal), `evidences/*.png` + `evidences/blackbox/*.png`.
- **Nguồn yêu cầu:** `client/Tidal.docx` (đã có bản tóm tắt VN `client/Tidal-tom-tat-tieng-viet.md`) — §2 (candidate/client/admin), §3 Yedi, §4 Tidal, §5 workflows, §6 MVP/phase.

## Related Code Files
- Create: `plans/260703-danh-gia-build-yedi-tidal/reports/00-methodology-and-requirements-checklist.md` (khung requirement + protocol).
- Create: `evidences/yedi/` (thư mục ảnh Yedi mới).
- Read: `client/Tidal.docx`, `client/Tidal-tom-tat-tieng-viet.md`, `client/credentials.txt`.
- Recover (git): các file dưới commit `07c6c5f` → khôi phục vào `reports/prior-tidal/` để tham chiếu.

## Implementation Steps
1. **Recover asset Tidal cũ:** `git show 07c6c5f:<path>` → lưu các doc + gap analysis vào `reports/prior-tidal/`. Ghi rõ đây là finding 2026-06-29, cần re-verify (Phase 2).
2. **Trích khung requirement từ docx** → checklist phẳng: mỗi dòng = 1 capability (candidate/client/admin/matching/compliance/workflow/MVP), có cột `Yedi` và `Tidal` để điền ✅/🟡/🔴 ở Phase 5. Chia theo đúng section docx.
3. **Chốt protocol black-box an toàn** (áp dụng Phase 2+3):
   - Tiền tố record test dễ nhận: `ZZTEST_<agent>_<timestamp>`.
   - Vòng đời: chụp ảnh trước → tạo → quan sát side-effect (relation, status, dashboard £/count) → chụp → **xoá** → chụp verify baseline.
   - Không đụng record thật; không sửa System settings; không export PII.
   - Mỗi platform 1 session browser riêng.
4. **Xác định công cụ crawl:** dùng browser automation (Playwright/agent-browser) đăng nhập bằng credential, hoặc `curl` cho recon read-only. Ghi lại route Filament chuẩn: `/admin/{resource}`, `/admin/{resource}/create`, `/admin/{resource}/{id}/edit`.
5. **Inventory resource menu** cho cả 2 platform (chỉ liệt kê, chưa test sâu) → biết bề mặt cần đánh giá.

## Success Criteria
- [ ] Asset Tidal cũ đã recover vào `reports/prior-tidal/`, đánh dấu ngày & trạng thái "cần re-verify".
- [ ] Checklist requirement từ docx dựng xong (khung 2 cột Yedi/Tidal, chưa điền).
- [ ] Protocol black-box viết rõ trong `00-methodology-and-requirements-checklist.md`.
- [ ] Danh sách resource (menu) của Yedi và Tidal đã liệt kê.

## Risk Assessment
- **Rủi ro:** finding cũ đã lỗi thời (build đổi) → mitigate bằng Phase 2 re-verify, không tin mù.
- **Rủi ro:** lộ credential/PII → không đưa credential/PII vào report, gitignore evidence nhạy cảm.
