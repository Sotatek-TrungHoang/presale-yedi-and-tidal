---
phase: 6
title: "Compliance-RightToWork"
status: pending
priority: P1
effort: "52d"
dependencies: []
---

# Phase 6: Compliance & Right-to-Work

## Tổng quan
Ngành staffing tại UK theo luật bắt buộc kiểm tra right-to-work + evidence trước khi candidate được làm việc.
Platform có **các trường status và các bảng config rỗng** nhưng **không có compliance engine** —
không có gì đảm bảo một candidate "Compliant" thực sự có đủ evidence yêu cầu.

## Hiện trạng (đã verify — gồm cả black-box behavioral test)
- 🟡 **DATA evidence đã tồn tại, nhưng không có bề mặt capture live** *(black-box + domain recon)*: tab
  Identification của candidate id=2 hiển thị **Photograph, Evidence of ID (image), Video verification (trình phát video), ID number**;
  tab Contracts hiển thị một **signed contract + link file** (`evidences/blackbox/t2-candidate-identification-tab.png`,
  `t2-candidate-contracts-tab.png`). Vậy **storage model cho evidence là thật**. NHƯNG **không có luồng
  capture live phía candidate** (không có front-end nào tồn tại — subdomain `app.` là placeholder nginx rỗng), và
  toàn bộ candidate đều là tài khoản dev `@ne6.studio` → dữ liệu này **rất có khả năng là dev/test seed**, không phải bằng chứng về một
  capture pipeline đang hoạt động. Build phần upload/capture phía candidate như **greenfield**; chỉ có storage schema là tái sử dụng được.
- ✅ **CRUD Required Evidence hoạt động** — tạo là một **modal/slide-over** (Title, Time-to-complete, Required), lưu được. (Vụ "`/create` rỗng" trước đó chỉ vì nó dạng modal.) (evidence: `t2-required-evidence-modal.png`, `t2-required-evidence-created.png`)
- ✅ **Workflow References đã có** — modal "Update references": repeater gồm Name/Telephone/Email/Status (vd "Sent to Referee"). Policy hệ thống **References required = 2**. (evidence: `t2-update-references-modal.png`)
- 🟡 Status compliance (Compliant / Non-compliant / Incomplete / Pending Approval) đặt thủ công qua "Update status" — là một **nhãn, không phải gate được tính toán**.
- 🔴 **Tạo Declarations BỊ HỎNG (bug production)** — trường Upload bắt buộc lỗi ở server-side (lỗi Livewire temp-upload `data.upload_id… failed to upload`); không thể tạo bất kỳ declaration nào. (evidence: `t2-declaration-upload-error.png`)
- 🔴 **Không có enforcement** — không có evidence UI nào cho thấy candidate non-compliant bị chặn khỏi booking; compliance chỉ mang tính khai báo.
- 🔴 Không có rules engine (evidence catalog → checklist → status tính toán), không track expiry, không tích hợp right-to-work.

## Mục tiêu mức Production
- **Required Evidence catalog** theo từng loại candidate/role (passport, visa/share-code, DBS, proof of address, NI, v.v.),
  mỗi mục có: cờ bắt buộc, expiry, các loại file chấp nhận.
- Workflow **upload + verification tài liệu** (submitted → under review → approved/rejected/expired) kèm reviewer queue.
- **Declarations** phát hành cho candidate, ký/xác nhận, được track.
- Thu thập **References** (target = 2): mời referee → ghi nhận phản hồi → status.
- **Kiểm tra right-to-work** (workflow reviewer thủ công hiện tại; tùy chọn Yoti/identity provider sau).
- **Status compliance tự tính** từ độ đầy đủ evidence + tính hợp lệ + references + declarations.
- **Enforcement gate**: chỉ candidate Compliant mới được offer/book (gắn với P5).
- Giám sát expiry + nhắc re-request.

## Ma trận Feature Gap
| # | Feature | Hiện tại | Mục tiêu | Gap |
|---|---------|---------|--------|-----|
| 6.1 | Trường status compliance | 🟡 nhãn thủ công | Gate tự tính | Rules engine |
| 6.2 | Required Evidence catalog | 🟡 CRUD hoạt động (modal), chưa config | Cấu hình theo role/type | Seed + theo role/type + file types/expiry |
| 6.3 | Upload tài liệu | 🔴 không có capture live (data=seed); storage schema đã có | Candidate upload theo từng mục | Build UI/luồng upload greenfield (P3); tái dùng storage |
| 6.4 | Workflow verification | 🔴 | Reviewer queue + các state | Workflow + admin UI |
| 6.5 | Track expiry | 🔴 | Track + re-request | Kiểm tra theo lịch (P10) |
| 6.6 | Phát hành/ký Declarations | 🔴 tạo BỊ HỎNG (bug upload) | Phát hành + ghi nhận xác nhận | Fix bug upload + luồng issue/sign |
| 6.7 | Thu thập References | 🟡 workflow đã có, policy=2 | Tự động mời referee + ghi nhận | Tự động hóa mời/ghi nhận (đã có nền) |
| 6.8 | Kiểm tra right-to-work | 🔴 | Workflow thủ công (+tùy chọn KYC) | Workflow trước, integration sau |
| 6.9 | Enforcement đủ điều kiện | 🔴 | Chặn booking candidate non-compliant | Gate ở P5 |
| 6.10 | Audit trail | 🔴 | Ai verify gì, khi nào | Log audit compliance |

## Phạm vi Build (phần gap)
- Build **compliance rules engine**: evidence catalog → checklist theo từng candidate → tính toán
  độ đầy đủ → status compliance → đủ điều kiện booking.
- Reviewer queue + các state verification tài liệu.
- Workflow References + declarations.
- Quy trình right-to-work thủ công hiện tại; giữ một integration seam cho Yoti/TrueLayer sau (gần P9).

## Đánh giá Rủi ro
- **Rủi ro pháp lý/quy định** nếu gating sai — một candidate non-compliant bị book là trách nhiệm pháp lý thật sự.
  Enforcement phải cứng, không phải mang tính khuyến nghị.
- "Compliant" hiện nay là một nhãn đặt tay trên test data → các rule thật chưa được định nghĩa; cần
  yêu cầu evidence thực tế của client làm đầu vào.
