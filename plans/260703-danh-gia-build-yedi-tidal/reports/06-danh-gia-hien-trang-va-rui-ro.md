> ## ⚠️ CẬP NHẬT SAU SOURCE AUDIT (2026-07-08)
> Đánh giá dưới đây là **black-box**. Source thật đã lật nhiều điểm — xem đầy đủ ở **[`../../260708-source-audit-yedi-tidal/reports/08-consolidated-audit-summary.md`]**. Tóm tắt đính chính:
> - **Completeness: ~8% → ~69–77% MVP** (có app Flutter ship v1.0.5+26 2 phía + API lifecycle/compliance/billing thật).
> - **"Billing vắng mặt tuyệt đối" → SAI**: engine DocGen+Jobs CÓ (buggy, không absent). **"Compliance chỉ nhãn thủ công" → SAI**: enforcement gate CÓ (generic, thiếu DBS-structured). Nhiều **nghi vấn IDOR → thực ra đã authorize đúng**. **VAT 20% CÓ tính**.
> - **Risk register cập nhật** (bảng đầy đủ ở report 08 §6): R6/R7/R8 phần lớn OVERTURN; R2/R4/R9/R10 CONFIRMED; R1 GIỮ (hạ mức — có gate nhưng thiếu DBS engine); R3 REFRAME (portal authz tốt, admin RBAC thô).
> - **Risk MỚI (source-only):** idempotency → invoice/payslip trùng; payslip PDF rỗng số tiền; token vĩnh viễn + secrets commit git = account-takeover; double-apply race (thiếu unique DB); FCM notifications hỏng end-user; no-401 handling; 0 test/CI; build script không portable.
> Giữ nội dung black-box cũ bên dưới để đối chiếu.

# §8.1 Đánh giá hiện trạng + §8.2 Rủi ro kỹ thuật (Yedi + Tidal)

> Nội bộ Sotatek · 2026-07-03 · dựa evidence Phase 2–5.

## §8.1 Hiện trạng: Dùng được / Cần fix / Cần rebuild

**Nguyên tắc:** cả 2 platform **chung 1 codebase** (Phase 4) → đánh giá áp dụng cho cả 2, khác biệt ghi rõ.

### ✅ DÙNG ĐƯỢC (tái sử dụng as-is / gần as-is) — "xương sống"
| Hạng mục | Ghi chú |
|---|---|
| Data model lõi | Candidate/Teacher (4 tab), Advert/Job (giàu: rate, charge %, shift, address, docs), Brand/School — thật, tái dùng tốt |
| Admin CRUD | Toàn bộ resource có list/create/edit, filter theo status, bulk action, toggle columns (chuẩn Filament) |
| Dashboard | Widget count + tài chính (Income/Expenditure/Charges/Profit) — khung có sẵn, chỉ cần wire số thật |
| System settings | Charge %, references required, invoice bank/terms, contract templates — cấu hình đầy đủ |
| Application (một phần) | Tạo Application + cập nhật quan hệ phái sinh (accepted-application, counter) chạy thật |
| Evidence storage | Photo/ID/video/contract lưu được (schema thật; capture là greenfield) |
| Config per-tenant | Yedi: 5 job-role giáo dục + 1 DBS catalog; Tidal: charge defaults |

### 🟡 CẦN FIX / HOÀN THIỆN (có scaffold, thiếu logic)
| Hạng mục | Thiếu gì |
|---|---|
| Application lifecycle | Có CRUD; thiếu events/state + apply logic |
| Compliance status | Nhãn thủ công; cần auto-compute + verification queue |
| Required Evidence | CRUD chạy; cần cấu hình rule per role/type |
| References | Workflow admin-side; cần automate (invite/capture) |
| Reporting | Widget count; cần wire số thật + filter/KPI |
| Contract templates | Rich-text có; cần generation template→PDF |
| **Bug production** | **Declarations create vỡ** (Livewire upload) — cần fix; báo client |

### 🔴 CẦN BUILD MỚI (greenfield — không có ở UI)
| Hạng mục | |
|---|---|
| **Portal candidate + client/school** | Không có front-end live (app.=403 cả 2) — toàn bộ self-service |
| **Booking/Allocation entity** | Chuỗi dừng sau Application; không có object booking |
| **Billing engine** | Invoice/Payslip generation — vắng mặt tuyệt đối (không nút New/Generate) |
| **Timesheet** | Không tồn tại |
| **Matching engine** | Không có (+ override, suggestions) |
| **Notification** | Email/SMS/in-app — không thấy |
| **RBAC + auth portal** | User không role/permission; không reset/2FA/verify/registration |
| **Availability** | Không model |
| **Compliance enforcement** | Không gate chặn book non-compliant |
| **Multi-tenancy chính thức** | Hiện là 2 deploy fork; cần multi-tenant foundation |
| **Yedi: engine compliance giáo dục** | DBS number/expiry, safeguarding training, document-expiry gate — critical |
| **Tidal: talent pool + client visibility** | Experience structured, pool by city/brand, coverage/fill/spend dashboard |

**Tóm tắt:** khoảng **1/4 platform** đã có (data model + admin CRUD + config); **3/4 là greenfield** (portal, engine giao dịch, compliance enforcement, non-functional). MVP mới ~8% hoàn thiện (chỉ admin dashboard ✅).

---

## §8.2 Rủi ro kỹ thuật (xếp theo mức nghiêm trọng)

| # | Rủi ro | Mức | Tác động |
|---|---|:---:|---|
| R1 | **Safeguarding Yedi**: không có DBS/safeguarding engine + không enforcement → có thể book giáo viên non-compliant/DBS hết hạn vào trường | 🔴 Critical | Pháp lý + an toàn trẻ em; là điểm chặn go-live Yedi |
| R2 | **Không có test/CI/CD** (giả định từ ngoài) | 🔴 High | Đổi code = rủi ro regression, nhất là money + compliance |
| R3 | **Không RBAC + không authorization policies** | 🔴 High | Mọi admin cùng quyền; khi mở portal = rủi ro rò rỉ dữ liệu chéo |
| R4 | **PII/GDPR**: giữ PII + ID/RTW/DBS docs; chưa thấy retention/erasure/SAR/encryption | 🔴 High | UK GDPR; đặc biệt nặng với dữ liệu trẻ em/giáo viên |
| R5 | **Bug production Declarations upload** (Livewire) | 🟡 Medium | Chức năng compliance hiện vỡ; fix nhanh nhưng lộ chất lượng QA |
| R6 | **Booking→billing chưa có engine** | 🟡 Medium | Rủi ro tính tiền sai khi build (charge %, VAT, PAYE/umbrella) → cần kế toán tư vấn |
| R7 | **Không có source code để chốt** | 🟡 Medium | Chất lượng code là biến ±15-20%; module rỗng có thể giấu backend thiếu hoặc có service ẩn |
| R8 | **2 codebase fork trôi dạt** (nếu không hợp nhất) | 🟡 Medium | Bug fix/feature 2 nơi; chi phí bảo trì gấp đôi dài hạn |
| R9 | **Upload không AV scan / signed URL** | 🟡 Medium | Rủi ro malware + rò file nhạy cảm |
| R10 | **Không backup/monitoring** (giả định) | 🟡 Medium | Mất dữ liệu / downtime không phát hiện |

**Điều kiện gỡ rủi ro nhanh:** (1) xin **source + Git** để chốt R7/R8; (2) ưu tiên R1 (safeguarding) là gate bắt buộc trước khi Yedi nhận traffic thật; (3) báo client bug R5 ngay (miễn phí, thiện chí).
</content>
