# Phase 6 — Reconciliation Gate (matrix 05 ↔ roadmap/proposal)

> Bước kiểm ngược bắt buộc trước khi phát hành proposal. Mục tiêu: **mọi ID trong ma trận Phase 5 phải map tới đúng 1 đích** — MVP (Tranche 1) / T2 (Tranche 2) / Future / Reuse (đã có) / Out (ngoài scope). ID nào không map được = FLAG, phải xử lý trước khi chốt.
> Lý do tồn tại: quá trình nén matrix (110 feature) → roadmap → proposal 1–2 trang là **lossy**. Không có gate này, vài dòng 🔴 bốc hơi im lặng (đã xảy ra: Referral/Training/Ratings rớt khỏi proposal draft v1).

## Cách dùng (mỗi lần cập nhật proposal)
1. Liệt kê mọi ID từ `05-requirements-traceability-matrix.md`.
2. Gán đích cho từng ID (cột "Đích").
3. Bất kỳ ID nào Đích trống, hoặc trạng thái 🔴/🟡 mà Đích = "Reuse" → **FLAG**.
4. Cross-check ngược: mở proposal .docx, mọi item MVP/T2 trong bảng này phải xuất hiện (được gọi tên hoặc gộp rõ trong 1 domain).

## Bảng reconciliation

Legend Đích: **MVP** = Tranche 1 · **T2** = Tranche 2 · **FUT** = Future/Advanced · **REUSE** = đã có, dùng as-is · **OUT** = ngoài scope engagement.

### Candidate/Worker (C1–C15)
| ID | Capability | Trạng thái | Đích | Map tới |
|---|---|:---:|:---:|---|
| C1 | Đăng ký self-service | 🔴 | MVP | P1 auth portal |
| C2 | Hồ sơ (live record) | 🔴 | MVP | P3 |
| C3 | Upload tài liệu | 🔴 | MVP | P3/P6 |
| C4 | Exp/skill/preference | 🔴 | MVP | P3 |
| C5 | **Availability** | 🔴 | MVP | P5 availability model + P3 UI |
| C6 | Xem job | 🔴 | MVP | P4 public job page |
| C7 | Apply/accept shift | 🔴 | MVP | P5 |
| C8 | Nhận xác nhận booking | 🔴 | MVP | P5 |
| C9 | Xem lịch sắp tới | 🔴 | MVP | P3 |
| C10 | Nộp timesheet | 🔴 | MVP | P7 |
| C11 | Track duyệt/thanh toán | 🔴 | MVP | P8 payslip view |
| C12 | Nhận notification | 🔴 | MVP | P10 |
| C13 | **Feedback/rating** | 🔴 | **T2** | Ratings/Feedback engine |
| C14 | **Training/onboarding** | 🔴 | **T2** | Training records |
| C15 | **Referral** | 🔴 | **T2** | Referral programme |

### Client/School (B1–B11)
| ID | Capability | Trạng thái | Đích | Map tới |
|---|---|:---:|:---:|---|
| B1 | Đăng ký | 🔴 | MVP | P1 |
| B2 | Gửi yêu cầu nhân sự | 🔴 | MVP | P2 |
| B3 | Ghi chú/yêu cầu đặc biệt | 🔴 | MVP | P2 |
| B4 | Xem candidate gợi ý | 🔴 | MVP | P5 matching |
| B5 | Duyệt/xác nhận booking | 🔴 | MVP | P5 |
| B6 | Xem booking sắp tới | 🔴 | MVP | P2 |
| B7 | Track attendance | 🔴 | MVP | P7 |
| B8 | Duyệt timesheet | 🔴 | MVP | P7 |
| B9 | **Feedback** | 🔴 | **T2** | Ratings/Feedback engine |
| B10 | Xem invoice/summary | 🔴 | MVP | P8 |
| B11 | Báo cáo cơ bản | 🔴 | MVP | P13 basic |

### Admin/Internal (A1–A18)
| ID | Capability | Trạng thái | Đích | Map tới |
|---|---|:---:|:---:|---|
| A1 | Xem candidate | ✅ | REUSE | admin CRUD |
| A2 | Duyệt/từ chối đăng ký | 🟡 | MVP | P1/P3 wire portal queue |
| A3 | Verify tài liệu | 🟡 | MVP | P6 verification workflow |
| A4 | Track compliance | 🟡 | MVP | P6 auto-compute |
| A5 | Tạo & quản lý booking | 🔴 | MVP | P5 Booking entity |
| A6 | Gán candidate vào shift | 🟡 | MVP | P5 allocation |
| A7 | Override matching | 🔴 | MVP | P5 (admin override) |
| A8 | Xem availability | 🔴 | MVP | P5 |
| A9 | Quản lý account client | ✅ | REUSE | CRUD Brands/Schools |
| A10 | Quản lý timesheet | 🔴 | MVP | P7 |
| A11 | Track booking status | 🔴 | MVP | P5 |
| A12 | Gửi notification | 🔴 | MVP | P10 |
| A13 | Hủy/no-show | 🔴 | MVP | P5 booking lifecycle |
| A14 | **Track feedback 2 chiều** | 🔴 | **T2** | Ratings/Feedback engine |
| A15 | Tạo báo cáo | 🟡 | MVP+T2 | P13 basic (MVP) → depth (T2) |
| A16 | Export data | 🔴 | MVP | P13 basic export |
| A17 | Manage region/role/rate | 🟡 | MVP | P12 config (region mới) |
| A18 | RBAC | 🔴 | MVP | P1 |

### Yedi-specific (Y1–Y10)
| ID | Capability | Trạng thái | Đích | Map tới |
|---|---|:---:|:---:|---|
| Y1 | DBS status + expiry | 🔴 | MVP-Yedi delta | Compliance giáo dục (gate go-live Yedi) |
| Y2 | Safeguarding training | 🔴 | MVP-Yedi delta | Compliance giáo dục |
| Y3 | Right to work | 🟡 | MVP | P6 |
| Y4 | References | 🟡 | MVP | P6 (đã có workflow admin) |
| Y5 | Qualifications structured | 🟡 | MVP-Yedi delta | Model mở rộng |
| Y6 | Employment history | 🔴 | MVP-Yedi delta | P3/model |
| Y7 | Document expiry flag trước book | 🔴 | MVP | P6 enforcement + Yedi delta |
| Y8 | Compliance warning/notes | 🔴 | MVP | P6 |
| Y9 | School booking flow | 🔴 | MVP | P5 |
| Y10 | **Education matching** | 🔴 | **T2** | Yedi education matching (age group/school type/reliability) |

### Tidal-specific (T1–T4)
| ID | Capability | Trạng thái | Đích | Map tới |
|---|---|:---:|:---:|---|
| T1 | Brand/retail/fragrance experience structured | 🔴 | MVP+T2 | P3 profile baseline (MVP) → tagging sâu (T2) |
| T2 | Talent pool theo city/brand | 🔴 | MVP+T2 | talent-pool cơ bản (MVP) → full (T2) |
| T3 | **Client visibility (coverage/fill/spend)** | 🔴 | **T2** | Tidal OS dashboard |
| T4 | Matching beauty | 🔴 | MVP | P5 matching baseline |

### Workflows (W1–W5)
| ID | Workflow | Trạng thái | Đích | Map tới |
|---|---|:---:|:---:|---|
| W1 | Registration | 🔴 | MVP | P1/P3 |
| W2 | Client booking | 🔴 | MVP | P5 |
| W3 | Timesheet | 🔴 | MVP | P7 |
| W4 | Compliance | 🟡 | MVP | P6 + enforcement |
| W5 | **Feedback** | 🔴 | **T2** | Ratings/Feedback engine |

### MVP list (M1–M13) — tất cả thuộc Tranche 1 theo định nghĩa
M1–M13 → MVP. Lưu ý **M6 Availability = MVP** (khớp C5) — phải được gọi tên trong scope proposal.

## Kết quả gate (draft v1 → v2)
FLAG phát hiện ở proposal draft v1 (đã sửa ở v2):
- **C5/A8/M6 Availability** — có trong estimate (P5) + roadmap nhưng **không được gọi tên** trong scope prose proposal → sửa: thêm tên vào scope Candidate portal MVP.
- **C13/B9/A14/W5 Ratings/Feedback** — teo dần, mất khỏi proposal → sửa: thêm 1 dòng T2.
- **C15 Referral** — rớt từ roadmap → sửa: thêm dòng T2.
- **C14 Training** — rớt từ roadmap → sửa: thêm dòng T2.
- **Notification cơ bản (M11/C12)** — có trong bảng effort P10 (MVP=14) nhưng thiếu trong scope prose Tranche 1 → sửa: thêm tên vào scope MVP.

Sau sửa v2: **mọi ID map được, không còn FLAG.**

## Điều khoản gate (đưa vào quy trình phase-06)
> Không phát hành proposal khi bảng này còn ID FLAG. Mọi item Đích=MVP/T2 phải truy được (được gọi tên hoặc gộp rõ) trong proposal .docx.
</content>
</invoke>
