# Phase 5 — Ma trận Traceability (Tidal.docx §2–§6 ↔ hiện trạng)

> Đối chiếu từng yêu cầu client với trạng thái đã verify (Phase 2 Tidal + Phase 3 Yedi), 2026-07-03.
> Legend: ✅ done (dùng as-is) · 🟡 partial (scaffold/admin-only/dở dang) · 🔴 missing (build mới).
> Vì Yedi = cùng codebase Tidal, đa số trạng thái **trùng nhau**; chênh lệch ghi rõ.
> Evidence: `02-tidal-reverify-delta.md`, `03-yedi-teardown-live-findings.md`, prior `tidal-blackbox-test-findings.md`.

## §2.1 Candidate/Worker side — **không có portal (app.=403) → self-service = 🔴 cả 2**
| # | Capability | Yedi | Tidal | Ghi chú |
|---|---|:---:|:---:|---|
| C1 | Đăng ký tài khoản self-service | 🔴 | 🔴 | Không portal; admin tạo hộ |
| C2 | Xây/sửa hồ sơ (live worker record) | 🔴 | 🔴 | Model có (admin-side) nhưng không self-service |
| C3 | Upload tài liệu | 🔴 | 🔴 | Storage có admin-side; không có luồng candidate upload |
| C4 | Kinh nghiệm/kỹ năng/preference | 🔴 | 🔴 | Chỉ field generic admin-side |
| C5 | Đặt availability | 🔴 | 🔴 | Không model availability |
| C6 | Xem cơ hội/job | 🔴 | 🔴 | Không portal, không public job page |
| C7 | Apply/accept shift | 🔴 | 🔴 | Application chỉ tạo admin-side |
| C8 | Nhận xác nhận booking | 🔴 | 🔴 | Không booking |
| C9 | Xem lịch sắp tới | 🔴 | 🔴 | — |
| C10 | Nộp timesheet | 🔴 | 🔴 | Không timesheet |
| C11 | Theo dõi trạng thái duyệt/thanh toán | 🔴 | 🔴 | — |
| C12 | Nhận notification | 🔴 | 🔴 | — |
| C13 | Nhận feedback/rating | 🔴 | 🔴 | Field Rating có admin-side; không hiển thị cho candidate |
| C14 | Training/onboarding | 🔴 | 🔴 | — |
| C15 | Referral | 🔴 | 🔴 | — |

## §2.2 Client/School side — **không có portal → 🔴 cả 2**
| # | Capability | Yedi | Tidal |
|---|---|:---:|:---:|
| B1 | Đăng ký tài khoản | 🔴 | 🔴 |
| B2 | Gửi yêu cầu nhân sự | 🔴 | 🔴 |
| B3 | Ghi chú/yêu cầu đặc biệt | 🔴 | 🔴 |
| B4 | Xem candidate gợi ý | 🔴 | 🔴 |
| B5 | Duyệt/xác nhận booking | 🔴 | 🔴 |
| B6 | Xem booking sắp tới | 🔴 | 🔴 |
| B7 | Theo dõi attendance | 🔴 | 🔴 |
| B8 | Duyệt timesheet | 🔴 | 🔴 |
| B9 | Feedback | 🔴 | 🔴 |
| B10 | Xem invoice/summary | 🔴 | 🔴 |
| B11 | Báo cáo cơ bản | 🔴 | 🔴 |

## §2.3 Admin/Internal — **phần mạnh nhất của build**
| # | Capability | Yedi | Tidal | Ghi chú |
|---|---|:---:|:---:|---|
| A1 | Xem tất cả candidate | ✅ | ✅ | List + detail đầy đủ |
| A2 | Duyệt/từ chối đăng ký | 🟡 | 🟡 | "Update status" (nhãn); không có hàng đợi đăng ký (no portal) |
| A3 | Verify tài liệu | 🟡 | 🟡 | Evidence storage + compliance label; không verification queue/workflow |
| A4 | Track compliance | 🟡 | 🟡 | Nhãn thủ công (4 status); không auto-compute |
| A5 | Tạo & quản lý booking | 🔴 | 🔴 | **Không có Booking entity** |
| A6 | Gán candidate vào shift | 🟡 | 🟡 | Tạo Application Accepted được; không allocation/booking object |
| A7 | Override matching thủ công | 🔴 | 🔴 | Không có matching engine |
| A8 | Xem availability | 🔴 | 🔴 | Không model |
| A9 | Quản lý account client/school | ✅ | ✅ | CRUD Brands/Schools |
| A10 | Quản lý timesheet | 🔴 | 🔴 | Không timesheet |
| A11 | Track booking status | 🔴 | 🔴 | Không booking |
| A12 | Gửi notification | 🔴 | 🔴 | Không thấy |
| A13 | Hủy/no-show | 🔴 | 🔴 | Không thấy |
| A14 | Track feedback 2 chiều | 🔴 | 🔴 | Chỉ field Rating tĩnh |
| A15 | Tạo báo cáo | 🟡 | 🟡 | Dashboard widget count/£; không report builder |
| A16 | Export data | 🔴 | 🔴 | Không thấy action export |
| A17 | Quản lý region/role/rate | 🟡 | 🟡 | Job Roles + Types of Work + charge config; region chưa thấy |
| A18 | RBAC | 🔴 | 🔴 | User không có role/permission |

## §3 Yedi-specific (education/compliance) — **gap lớn nhất riêng Yedi**
| # | Capability | Yedi | Ghi chú |
|---|---|:---:|---|
| Y1 | DBS status + expiry | 🔴 | Chỉ 1 catalog "DBS Evidence"; không track number/expiry |
| Y2 | Safeguarding training | 🔴 | Không field/record |
| Y3 | Right to work | 🟡 | Self-declaration boolean ở Work tab |
| Y4 | References | 🟡 | Workflow admin-side (Sent to Referee) |
| Y5 | Qualifications | 🟡 | 1 field "Qualification" + role QTS (nhãn); không structured |
| Y6 | Employment history | 🔴 | Không structured |
| Y7 | Document expiry flag trước book | 🔴 | Không có |
| Y8 | Compliance warning/notes | 🔴 | Chỉ status label |
| Y9 | School booking flow | 🔴 | Không booking |
| Y10 | Matching giáo dục | 🔴 | Không matching |

## §4 Tidal-specific (beauty/retail)
| # | Capability | Tidal | Ghi chú |
|---|---|:---:|---|
| T1 | Brand/retail/fragrance experience trên hồ sơ | 🔴 | Không field experience structured (chỉ Qualification/role/type generic) |
| T2 | Talent pool theo city/brand | 🔴 | Không filter/pool engine |
| T3 | Client visibility (coverage/fill/spend) | 🔴 | Không portal client |
| T4 | Matching beauty | 🔴 | Không matching |

## §5 Workflows (chạy tới đâu)
| # | Workflow | Yedi | Tidal | Đứt gãy ở đâu |
|---|---|:---:|:---:|---|
| W1 | Registration | 🔴 | 🔴 | Không self-registration; bắt đầu = admin tạo tay |
| W2 | Client booking | 🔴 | 🔴 | Dừng sau Application (không request→match→booking→confirm) |
| W3 | Timesheet | 🔴 | 🔴 | Không tồn tại |
| W4 | Compliance | 🟡 | 🟡 | Upload+verify+status có admin-side; **thiếu expiry flag + enforcement gate** |
| W5 | Feedback | 🔴 | 🔴 | Chỉ field Rating tĩnh |

## §6 MVP list — đo khoảng cách tới MVP
| # | MVP item | Yedi | Tidal |
|---|---|:---:|:---:|
| M1 | Đăng ký candidate | 🔴 | 🔴 |
| M2 | Đăng ký client/school | 🔴 | 🔴 |
| M3 | Admin dashboard | ✅ | ✅ |
| M4 | Quản lý hồ sơ | 🟡 | 🟡 |
| M5 | Upload tài liệu | 🟡 | 🟡 |
| M6 | Availability | 🔴 | 🔴 |
| M7 | Tạo booking | 🔴 | 🔴 |
| M8 | Gán candidate | 🟡 | 🟡 |
| M9 | Xác nhận booking | 🔴 | 🔴 |
| M10 | Timesheet | 🔴 | 🔴 |
| M11 | Notification cơ bản | 🔴 | 🔴 |
| M12 | Compliance status cơ bản | 🟡 | 🟡 |
| M13 | Reporting/export cơ bản | 🟡 | 🟡 |

**% MVP (cả 2 platform, gần như bằng nhau vì chung code):**
- ✅ Done hoàn toàn: **1/13 (~8%)** — chỉ Admin dashboard.
- 🟡 Có scaffold một phần: 5/13 (M4/M5/M8/M12/M13).
- 🔴 Thiếu hẳn: 7/13 (M1/M2/M6/M7/M9/M10/M11).
- → **Khoảng cách tới MVP ổn định còn rất lớn** (~92% cần build/hoàn thiện). Toàn bộ self-service (candidate+client portal), booking, timesheet, notification, availability là greenfield.

---

## Top gap CHUNG (cả 2 platform — build 1 lần nếu shared)
1. Không có **portal** candidate + client/school (self-service = 0).
2. Không có **Booking/Allocation entity** (chuỗi dừng sau Application).
3. Không có **engine billing** (invoice/payslip generation).
4. Không có **timesheet**.
5. Không có **matching engine**.
6. Không có **notification**.
7. Không có **RBAC** + không có **auth portal** (reset/2FA/verify).
8. Compliance = nhãn thủ công, **không enforcement/expiry flag**.
9. Không có **availability**, export, reporting sâu.

## Gap RIÊNG
- **Yedi:** engine compliance giáo dục thực (DBS number/expiry, safeguarding training, document-expiry gate chặn book teacher non-compliant) — critical vì safeguarding trẻ em.
- **Tidal:** structured brand/retail/fragrance experience + talent pool by city/brand + client-visibility dashboard ("Tidal OS").

## Confidence
- Trạng thái dựa **black-box (không source)**: "🔴 verified vắng mặt" (không tìm thấy đường nào ở UI) khác "chưa kiểm được". Hầu hết 🔴 ở đây là **verified vắng mặt** (đã soi toàn bộ nav + action toolbar). Một số backend ẩn (service generation invoice/booking chưa wire UI) chỉ chốt được bằng source (two-step).
</content>
