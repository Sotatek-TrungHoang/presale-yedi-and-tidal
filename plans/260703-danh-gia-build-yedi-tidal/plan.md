---
title: "Đánh giá build hiện tại Yedi + Tidal (đối chiếu yêu cầu client)"
description: "Plan chạy audit/đánh giá 2 platform staffing live (Yedi + Tidal, Laravel+Filament) đối chiếu yêu cầu client trong Tidal.docx. Deliverable: hiện trạng, cái dùng được/fix/rebuild, rủi ro, route MVP nhanh nhất, roadmap, ước tính effort+cost, khuyến nghị shared-backend vs tách rời. Tất cả deliverable bằng tiếng Việt."
status: complete
priority: P1
branch: "main"
tags: [presale, evaluation, audit, staffing, filament, yedi, tidal]
blockedBy: []
blocks: []
created: "2026-07-03T07:36:06.134Z"
createdBy: "ck:plan"
source: skill
---

# Đánh giá build hiện tại Yedi + Tidal (đối chiếu yêu cầu client)

## Overview

Plan **đánh giá (audit) 2 platform staffing đang chạy live** — không phải plan viết code.
Output cuối là bộ deliverable client yêu cầu trong `client/Tidal.docx` §8.

**Đối tượng đánh giá (đã verify reachable 2026-07-03):**
- **Tidal** — `admin.tidalagency.co.uk/admin` — Laravel + **Filament** + Livewire (200 OK).
- **Yedi** — `admin.yedi.group/admin` — Laravel + **Filament** + Livewire (200 OK). **Cùng stack với Tidal.**
- `app.tidalagency.co.uk` & `app.yedi.group` → **cả 2 đều 403 placeholder** (không có portal live).
- Credential: `client/credentials.txt` (Yedi + Tidal admin).

**Bối cảnh quan trọng — tái dùng công sức cũ:**
Trong git history (commit `07c6c5f`, đã bị commit `remove` xoá khỏi working tree) có sẵn **đánh giá Tidal đầy đủ + verified**: teardown live, black-box behavioral test 47 ảnh, gap analysis 14 domain, effort breakdown, estimate, proposal. **Tidal đã được đánh giá kỹ.** Cái **CHƯA từng làm** là **Yedi** (trước đây không có login) và **so sánh chéo Yedi↔Tidal** để trả lời câu hỏi chiến lược của client (shared backend hay tách rời).

**Nguyên tắc:** tái dùng finding Tidal cũ (recover từ git) + re-verify nhẹ (data có thể đổi từ 29/06 → 03/07), dồn công sức mới vào **Yedi** và **cross-platform compare**.

## Quyết định đã chốt với user
- **Test depth:** Safe black-box — tạo record test → quan sát hành vi → xoá sạch → verify baseline. Áp dụng cho cả Yedi + Tidal.
- **Ủy quyền ghi production (Yedi):** client cho phép free test (tạo/ghi) miễn **cleanup sạch sau đó**. Không cần né riêng luồng compliance/safeguarding — vẫn giữ nguyên tắc không export PII ra ngoài. (Validation S1)
- **Nguồn dữ liệu:** **black-box trước** → nếu cần chốt số chắc hơn thì **xin source/DB read-only ở bước sau**, không block Phase 4/6. (Validation S1)
- **Ngôn ngữ deliverable:** **Tất cả tiếng Việt — phục vụ nội bộ team presale Sotatek.** Bản English client-facing (nếu client UK cần) là việc TÁCH RIÊNG, ngoài scope plan này. (Validation S1)
- **Độ sâu re-verify Tidal (Phase 2):** **re-verify rộng** (duyệt lại toàn bộ resource, không chỉ 6 headline finding) phòng build đổi nhiều từ 29/06→03/07. (Validation S1)

## Cách đánh giá (maturity legend — dùng xuyên suốt)
- ✅ **Done** — có & dùng được as-is.
- 🟡 **Partial** — model/scaffold có nhưng logic/UI/flow dở dang.
- 🔴 **Missing** — không có; build mới.

## Phases

| Phase | Name | Status | Priority |
|-------|------|--------|----------|
| 1 | [Setup-Methodology](./phase-01-setup-methodology.md) — recover asset cũ, protocol test an toàn, dựng khung requirement từ docx | ✅ Complete | P1 |
| 2 | [Tidal-ReVerify](./phase-02-tidal-reverify.md) — re-verify rộng toàn resource Tidal (không chỉ 6 headline finding) | ✅ Complete | P2 |
| 3 | [Yedi-Live-Eval](./phase-03-yedi-live-eval.md) — teardown + black-box Yedi (phần mới lớn nhất) | ✅ Complete | P1 |
| 4 | [Cross-Platform-Compare](./phase-04-cross-platform-compare.md) — so sánh chéo → shared vs tách rời | ✅ Complete | P1 |
| 5 | [Requirements-Traceability](./phase-05-requirements-traceability.md) — map từng yêu cầu docx → trạng thái/platform | ✅ Complete | P1 |
| 6 | [Consolidated-Deliverables](./phase-06-consolidated-deliverables.md) — assessment, rủi ro, MVP route, roadmap, effort+cost | ✅ Complete | P1 |

## Kết quả (2026-07-03)
Audit hoàn tất. Deliverable ở `reports/` — điểm truy cập: **`reports/06-assessment-noibo-tieng-viet.md`**.
**3 kết luận chính:** (1) Yedi = cùng codebase Tidal (deploy riêng + relabel/config); (2) cả 2 mới là admin panel, ~8% MVP — portal/booking/billing/timesheet/matching/compliance-enforcement là greenfield, Yedi thiếu engine DBS/safeguarding thực (gap critical); (3) khuyến nghị shared multi-tenant (FE/compliance riêng ngành). Ước tính MVP ~660md (~£125–156k), full ~870md; cần Phase 0 source-audit để chốt fixed-price.

## Dependencies

Thứ tự build-order (nội bộ plan này, không cross-plan):
- P1 gate tất cả (protocol + khung requirement + asset cũ).
- P2 và P3 độc lập nhau, **có thể chạy song song** (2 platform khác nhau).
- P4 cần P2 + P3 xong (cần data cả 2 platform để so sánh).
- P5 cần P2 + P3 (map hiện trạng từng platform vào requirement).
- P6 cần P4 + P5 (tổng hợp thành deliverable client).

## Deliverable cuối (map thẳng vào Tidal.docx §8 — tất cả tiếng Việt)
1. Đánh giá hiện trạng từng platform (dùng được / fix / rebuild).
2. Rủi ro kỹ thuật.
3. Con đường nhanh nhất tới MVP ổn định.
4. Product roadmap đề xuất.
5. Ước tính thời gian & chi phí.
6. Khuyến nghị kiến trúc: Yedi & Tidal shared backend hay tách rời (có bằng chứng từ P4).

## Ràng buộc & lưu ý an toàn
- **Production của client** — chỉ safe black-box: tạo record test có tiền tố nhận biết (vd `ZZTEST_`), xoá ngay, verify list về baseline, chụp ảnh trước/sau.
- **KHÔNG** đụng dữ liệu thật của candidate/brand/school (PII). Không export PII ra ngoài.
- **KHÔNG** commit `client/credentials.txt` hay bất kỳ ảnh chứa PII lên git remote.
- Ảnh bằng chứng lưu `evidences/` (Tidal cũ) + `evidences/yedi/` (mới), gitignore nếu chứa PII.

## Validation Log

### Session 1 — 2026-07-03
**Trigger:** `/ck:plan validate` — critical-questions interview trước khi bắt đầu audit.
**Questions asked:** 4

#### Verification Results
- **Tier:** Full (6 phases) — nhưng đây là plan audit, không có codebase để grep; verify tập trung vào asset git + file client mà plan tái dùng.
- **Claims checked:** 11 | **Verified:** 11 | **Failed:** 0 | **Unverified:** 0
- Verified: `client/Tidal.docx`, `client/Tidal-tom-tat-tieng-viet.md`, `client/credentials.txt` tồn tại; commit `07c6c5f` tồn tại và chứa đủ: 3 doc Tidal (`tidal-teardown-live-findings.md`, `tidal-blackbox-test-findings.md`, `tidal-agency-analysis.md`), 4 file estimate/effort/proposal (`tidal-yedi-effort-breakdown-by-feature.md`, `tidal-yedi-estimate-from-feature-gap.md`, `tidal-yedi-proposal.md`, `tidal-yedi-uoc-tinh-tu-gap-analysis.md`), gap analysis 14 phase (EN) + bản dịch `vi/` (14 phase), toàn bộ evidence PNG.
- **Ghi chú:** prior gap analysis đã có sẵn bản `vi/` → Phase 6 có thể tái dùng bản dịch VN, không phải dịch lại từ đầu.

#### Questions & Answers

1. **[Risk/Ủy quyền]** Phase 3 tạo record ZZTEST_ trực tiếp trên production Yedi (platform giáo dục có PII + safeguarding/DBS). Mức ủy quyền client?
   - Options: Read-only | Black-box có ghi (đã có OK client) | Ghi giới hạn né PII
   - **Answer (Other):** "free test. sau đó nhớ clean up là được"
   - **Rationale:** Client cho phép ghi/xóa test trên production; ràng buộc là cleanup sạch. Không cần carve-out riêng cho luồng safeguarding → Phase 3 giữ đầy đủ black-box behavioral test. Vẫn giữ nguyên tắc không export PII.

2. **[Architecture/Risk]** Kết luận shared-vs-tách (P4) + effort/cost (P6) hiện dựa 100% black-box, không source. Xin source trước?
   - Options: Black-box only | Xin source/DB read-only trước | Black-box now, source sau nếu cần
   - **Answer:** Black-box now, source sau nếu cần
   - **Rationale:** Hai bước — chạy black-box ra bản nháp + đánh dấu chỗ cần source, rồi mới xin đúng phần thiếu. Không block P4/P6; kết luận kèm confidence.

3. **[Scope]** Client UK nhưng plan chốt "tất cả tiếng Việt". Bản proposal cuối phục vụ ai?
   - Options: Tiếng Việt (nội bộ Sotatek) | VN nội bộ + EN client-facing | Chỉ English
   - **Answer:** Tiếng Việt (nội bộ Sotatek)
   - **Rationale:** Deliverable VN phục vụ team presale Sotatek nội bộ. Bản EN gửi client UK là việc tách riêng, ngoài scope plan này → Phase 6 không cần sinh bản EN.

4. **[Scope/Assumption]** Phase 2 là delta pass nhẹ (chỉ 6 headline finding). Đủ chưa?
   - Options: Delta 6 điểm là đủ | Re-verify rộng hơn | Bỏ re-verify
   - **Answer:** Re-verify rộng hơn
   - **Rationale:** Duyệt lại toàn bộ resource Tidal (không chỉ 6 điểm) phòng build đổi nhiều 29/06→03/07. Phase 2 effort tăng 0.5d→1d.

#### Confirmed Decisions
- Yedi black-box: **được ghi/xóa production**, ràng buộc cleanup sạch — Phase 3 full behavioral test.
- Nguồn: **black-box trước, source sau nếu cần** — không block P4/P6.
- Ngôn ngữ: **VN nội bộ Sotatek**; EN client-facing ngoài scope.
- Phase 2: **re-verify rộng** toàn resource Tidal (không giới hạn 6 điểm).

#### Impact on Phases
- **Phase 2:** đổi từ "strict 6 điểm, không mở rộng" → re-verify rộng toàn resource; effort 0.5d→1d.
- **Phase 3:** xác nhận ủy quyền ghi production; bỏ ràng buộc "né safeguarding" (chỉ giữ không-export-PII).
- **Phase 4/6:** thêm ghi chú two-step nguồn dữ liệu (black-box now, source sau).
- **Phase 6:** làm rõ deliverable VN là nội bộ Sotatek; EN ngoài scope; tái dùng bản dịch `vi/` sẵn có.

### Whole-Plan Consistency Sweep
- Files reread: plan.md, phase-01…06.
- Decision deltas checked: 4 (Yedi write-auth, two-step source, VN-internal scope, Phase 2 broaden).
- Reconciled stale references: 5 — phases table "delta pass" → "re-verify rộng"; Phase 2 title/overview/steps/success/effort; Phase 6 H1 + `proposal-client` file → `assessment-noibo`, step 6 + success criteria wording; Phase 3 non-functional (write authorized); Phase 4 two-step note.
- Unresolved contradictions: 0.
