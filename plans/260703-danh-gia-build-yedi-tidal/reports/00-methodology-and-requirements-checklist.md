# Phase 1 — Methodology & Requirements Checklist

> Nền cho toàn bộ audit Yedi + Tidal. Recover asset Tidal cũ, chốt protocol black-box an toàn, dựng khung requirement từ `client/Tidal.docx` (§2–§6) làm xương sống traceability (Phase 5).
> Ngày: 2026-07-03 · Ngôn ngữ deliverable: **tiếng Việt (nội bộ Sotatek)**.

---

## 1. Asset Tidal cũ đã recover (từ git `07c6c5f`)

Đã recover vào `reports/prior-tidal/` — **finding gốc 2026-06-29, cần re-verify (Phase 2)** vì build/data có thể đổi:

| File | Nội dung |
|------|----------|
| `tidal-teardown-live-findings.md` | Bóc tách live: resource/form/field, cái có/thiếu |
| `tidal-blackbox-test-findings.md` | 6 finding hành vi (47 ảnh) — booking chain, billing, compliance, RBAC, domain recon |
| `tidal-agency-analysis.md` | Phân tích ban đầu |
| `tidal-yedi-effort-breakdown-by-feature.md` | WBS per-feature (~110 feature, md + $) |
| `tidal-yedi-estimate-from-feature-gap.md` (+ `-uoc-tinh-tu-gap-analysis.md` VN) | Roll-up: MVP ~660md, Full ~870md |
| `tidal-yedi-proposal.md` | Proposal draft v1 |
| `gap-analysis-en/` + `gap-analysis-vi/` | 14 domain gap analysis (EN + bản dịch VN sẵn có → tái dùng Phase 6) |

Evidence PNG (59 ảnh) restore vào `evidences/` + `evidences/blackbox/` (gitignored — có thể chứa PII seed).

**6 headline finding Tidal (2026-06-29) — checklist tối thiểu bắt buộc re-verify:**
1. Booking chain: Application CRUD + aggregation **chạy**; **không** Booking entity; advert status **không** auto-transition; **không** auto-gen invoice/payslip.
2. Invoice/Payslip generation: **vắng mặt tuyệt đối** (không nút New/Generate ở bất kỳ resource).
3. Compliance: Required Evidence + References + storage (ID/video/contract) **thật**; **Declarations create vỡ** (Livewire upload bug); **không enforcement**.
4. Advert lifecycle: enum free-select 6 status, **không state machine/approval guard**.
5. Auth: admin login chạy; **không RBAC**; identity nghi polymorphic; không portal auth/reset/2FA.
6. Domain: **không front-end brand/candidate live** (`app.` = 403 placeholder); evidence data nghi dev seed `@ne6.studio`.

---

## 2. Protocol black-box an toàn (áp dụng Phase 2 + 3)

Client **ủy quyền free test (ghi/xóa) trên production**, ràng buộc: **cleanup sạch + không export PII**.

**Vòng đời mỗi test:**
1. Chụp ảnh **trước** (list + số dashboard = baseline).
2. **Tạo** record test, tiền tố nhận biết: `ZZTEST_<agent>_<timestamp>`.
3. **Quan sát side-effect**: relation cập nhật? status auto-change? dashboard £/count đổi? action nào xuất hiện?
4. Chụp ảnh **sau**.
5. **Xóa** record test.
6. Chụp ảnh **verify baseline** (list về đúng số ban đầu).

**Ràng buộc cứng:**
- KHÔNG đụng/sửa record thật (candidate/brand/school/educator).
- KHÔNG sửa System settings (chỉ đọc).
- KHÔNG export PII ra ngoài; không chụp cận PII thật — che nếu cần.
- Mỗi platform 1 session browser riêng.
- Credential chỉ ở `client/credentials.txt` (gitignored) — không đưa vào report/ảnh.

**Công cụ:** browser automation (Playwright MCP / agent-browser) đăng nhập admin; `curl` read-only cho domain recon.
Route Filament chuẩn: `/admin/{resource}` (list), `/admin/{resource}/create`, `/admin/{resource}/{id}/edit`. (Tidal: Brands=`/advertisers`, Candidates=`/applicants`.)

---

## 3. Khung requirement từ `Tidal.docx` (§2–§6) — 2 cột điền ở Phase 5

Legend maturity: ✅ Done (dùng as-is) · 🟡 Partial (scaffold/dở dang) · 🔴 Missing (build mới) · ❔ chưa verify.

### §2.1 — Candidate / Worker side
| # | Capability | Yedi | Tidal |
|---|-----------|:----:|:-----:|
| C1 | Đăng ký tài khoản (self-service) | ❔ | ❔ |
| C2 | Xây & sửa hồ sơ (live worker record, không phải form 1 lần) | ❔ | ❔ |
| C3 | Upload tài liệu (ID/RTW/qualification) | ❔ | ❔ |
| C4 | Thêm kinh nghiệm / kỹ năng / role preference / địa điểm | ❔ | ❔ |
| C5 | Đặt availability | ❔ | ❔ |
| C6 | Xem cơ hội / job (browse) | ❔ | ❔ |
| C7 | Apply / accept shift | ❔ | ❔ |
| C8 | Nhận xác nhận booking | ❔ | ❔ |
| C9 | Xem lịch sắp tới | ❔ | ❔ |
| C10 | Nộp timesheet | ❔ | ❔ |
| C11 | Theo dõi trạng thái duyệt / thanh toán | ❔ | ❔ |
| C12 | Nhận notification | ❔ | ❔ |
| C13 | Nhận feedback / rating | ❔ | ❔ |
| C14 | Truy cập training / onboarding | ❔ | ❔ |
| C15 | Referral (giới thiệu ứng viên) | ❔ | ❔ |

### §2.2 — Client / School side
| # | Capability | Yedi | Tidal |
|---|-----------|:----:|:-----:|
| B1 | Đăng ký tài khoản | ❔ | ❔ |
| B2 | Gửi yêu cầu nhân sự (role/location/date/time/rate) | ❔ | ❔ |
| B3 | Thêm ghi chú / yêu cầu đặc biệt | ❔ | ❔ |
| B4 | Xem candidate được gợi ý | ❔ | ❔ |
| B5 | Duyệt / xác nhận booking | ❔ | ❔ |
| B6 | Xem booking sắp tới | ❔ | ❔ |
| B7 | Theo dõi attendance | ❔ | ❔ |
| B8 | Duyệt timesheet | ❔ | ❔ |
| B9 | Để lại feedback | ❔ | ❔ |
| B10 | Xem invoice / booking summary | ❔ | ❔ |
| B11 | Báo cáo cơ bản | ❔ | ❔ |

### §2.3 — Admin / Internal (phần quan trọng nhất)
| # | Capability | Yedi | Tidal |
|---|-----------|:----:|:-----:|
| A1 | Xem tất cả candidate | ❔ | ❔ |
| A2 | Duyệt / từ chối đăng ký | ❔ | ❔ |
| A3 | Verify tài liệu | ❔ | ❔ |
| A4 | Track compliance | ❔ | ❔ |
| A5 | Tạo & quản lý booking | ❔ | ❔ |
| A6 | Gán candidate vào shift | ❔ | ❔ |
| A7 | Override matching thủ công | ❔ | ❔ |
| A8 | Xem availability | ❔ | ❔ |
| A9 | Quản lý account client/school | ❔ | ❔ |
| A10 | Quản lý timesheet (duyệt/từ chối/query) | ❔ | ❔ |
| A11 | Track booking status | ❔ | ❔ |
| A12 | Gửi notification | ❔ | ❔ |
| A13 | Quản lý hủy / no-show | ❔ | ❔ |
| A14 | Track feedback 2 chiều | ❔ | ❔ |
| A15 | Tạo báo cáo | ❔ | ❔ |
| A16 | Export data | ❔ | ❔ |
| A17 | Quản lý region / role / rate / location | ❔ | ❔ |
| A18 | RBAC (roles/permissions cho admin) | ❔ | ❔ |

### §3 — Yedi-specific (education / compliance mạnh)
| # | Capability | Yedi | Tidal (N/A) |
|---|-----------|:----:|:-----------:|
| Y1 | DBS status + ngày hết hạn/gia hạn | ❔ | — |
| Y2 | Safeguarding training tracking | ❔ | — |
| Y3 | Right-to-work check | ❔ | — |
| Y4 | References (giáo dục) | ❔ | — |
| Y5 | Qualifications | ❔ | — |
| Y6 | Employment history | ❔ | — |
| Y7 | Document expiry flag trước khi book vào trường | ❔ | — |
| Y8 | Compliance warning / internal notes | ❔ | — |
| Y9 | School booking flow | ❔ | — |
| Y10 | Matching giáo dục (DBS/age group/school type/reliability) | ❔ | — |

### §4 — Tidal-specific (beauty/retail/experiential)
| # | Capability | Tidal | Yedi (N/A) |
|---|-----------|:-----:|:----------:|
| T1 | Brand / retail / fragrance experience trên hồ sơ | ❔ | — |
| T2 | Talent pool theo city / brand | ❔ | — |
| T3 | Client visibility (upcoming/confirmed/coverage/fill rate/spend) | ❔ | — |
| T4 | Matching beauty (brand/category/language/rate expectation/training) | ❔ | — |

### §5 — Workflows (chạy được tới đâu)
| # | Workflow | Yedi | Tidal |
|---|----------|:----:|:-----:|
| W1 | Registration: đăng ký → hồ sơ → upload → admin review → duyệt → match | ❔ | ❔ |
| W2 | Client booking: request → gợi ý → admin duyệt → notify → accept → chốt → status | ❔ | ❔ |
| W3 | Timesheet: submit → client duyệt → admin review → trigger invoice → status | ❔ | ❔ |
| W4 | Compliance: upload → verify → lưu expiry → flag → chặn non-compliant book | ❔ | ❔ |
| W5 | Feedback: sau booking → track reliability → dùng cho matching sau | ❔ | ❔ |

### §6 — MVP list (đo "khoảng cách tới MVP")
| # | MVP item | Yedi | Tidal |
|---|----------|:----:|:-----:|
| M1 | Đăng ký candidate | ❔ | ❔ |
| M2 | Đăng ký client/school | ❔ | ❔ |
| M3 | Admin dashboard | ❔ | ❔ |
| M4 | Quản lý hồ sơ | ❔ | ❔ |
| M5 | Upload tài liệu | ❔ | ❔ |
| M6 | Availability | ❔ | ❔ |
| M7 | Tạo booking | ❔ | ❔ |
| M8 | Gán candidate | ❔ | ❔ |
| M9 | Xác nhận booking | ❔ | ❔ |
| M10 | Timesheet | ❔ | ❔ |
| M11 | Notification cơ bản | ❔ | ❔ |
| M12 | Compliance status cơ bản | ❔ | ❔ |
| M13 | Reporting / export cơ bản | ❔ | ❔ |

---

## 4. Bảng đối tượng & trạng thái reachable (verify 2026-07-03)
| Target | URL | Trạng thái |
|--------|-----|-----------|
| Tidal admin | `admin.tidalagency.co.uk/admin` | 200 OK — Laravel/Filament/Livewire |
| Yedi admin | `admin.yedi.group/admin` | 200 OK — Laravel/Filament/Livewire (cùng stack) |
| Tidal app | `app.tidalagency.co.uk` | 403 placeholder (không portal) |
| Yedi app | `app.yedi.group` | 403 placeholder (không portal) |

---

## 5. Trạng thái nguồn dữ liệu (two-step)
- **Bước 1 (plan này):** black-box + fingerprint → kết luận nháp + confidence, đánh dấu chỗ cần source.
- **Bước 2 (sau, nếu cần chốt chắc):** xin source/DB read-only cho đúng phần thiếu. **Không block** Phase 4/6.
</content>
</invoke>
