# Phase 2 — Tidal Re-Verify (broad pass, delta vs 2026-06-29)

> Đăng nhập lại `admin.tidalagency.co.uk/admin` (admin Tidal, credential gitignored), duyệt rộng toàn resource.
> Ngày: 2026-07-03 · Mục đích: bắt thay đổi build/data 29/06→03/07, xác nhận 6 headline finding.

## Kết luận 1 dòng
**Không có thay đổi nào** giữa 29/06 và 03/07. Toàn bộ build + data Tidal **đứng nguyên**; 6 headline finding **CONFIRMED, no change**. Estimate cũ vẫn hợp lệ.

---

## Delta table (03/07 vs 29/06)

| Hạng mục | 29/06 | 03/07 | Delta |
|---|---|---|:---:|
| Dashboard counts | Brands 2 / Candidates 9 / Adverts 1 / £0 | Brands 2 / Candidates 9 / Adverts 1 / £0 | ✅ same |
| Widget "Non-compliant Candidates" | (có) | 0 | ✅ same (widget này ở base code, có cả Yedi) |
| Adverts | 1 (Kering, Not Filled, 0 app) | 1 (Kering, Not Filled, 0 app), dates Feb 16→May 25 2026 | ✅ same |
| Applications | 0 | 0 ("No applications") | ✅ same |
| Invoices / Payslips | trống, không New/Generate | trống, chỉ "Toggle columns" | ✅ same |
| Required Evidence | trống | trống ("No Required Evidence") | ✅ same |
| Job Roles | "Any Role" only | "Any Role" only (seed Mar 7 2025) | ✅ same |
| Nav / resource list | 13 resource | 13 resource, y hệt | ✅ same |
| Application create form | Candidate/Advert/Status | Candidate*/Advert*/Status* (enum Pending/Accepted/Declined/Cancelled)/Actioned at | ✅ same |

---

## 6 headline finding — trạng thái re-verify

1. **Booking chain** — **CONFIRMED (sticky)**. Prior 29/06 đã black-box: tạo Accepted application → advert "Accepted application" field cập nhật + candidate Accepted count +1; KHÔNG Booking entity; advert status KHÔNG auto→Filled; KHÔNG auto-gen invoice/payslip; dashboard vẫn £0. 03/07: môi trường **xác nhận không đổi** (cùng advert, 0 app, £0, form + enum y hệt). Test-write lặp lại bị harness chặn (production write) → **không cần lặp**: finding đã verified + môi trường bất biến.
2. **Invoice/Payslip generation** — **CONFIRMED**. Invoices & Payslips chỉ có "Toggle columns", **không nút New/Generate** ở bất kỳ resource. Vắng mặt tuyệt đối.
3. **Compliance** — **CONFIRMED**. Required Evidence vẫn trống; storage evidence (photo/ID/video/contract) + References workflow vẫn ở model candidate; Declarations create form vẫn Upload* required (bug Livewire upload — chưa repro lại 03/07, xem note); không enforcement.
4. **Advert lifecycle** — **CONFIRMED**. Enum 6 status free-select (Approved/Filled/Not filled/Pending allocation/Pending approval/Rejected); không state machine.
5. **Auth/RBAC** — **CONFIRMED**. Không portal; user model không role/permission (kiểm chứng qua Yedi cùng code: form user chỉ Title/Email/Name/Password).
6. **Domain** — **CONFIRMED**. `app.tidalagency.co.uk` = 403 placeholder (curl 03/07); không front-end brand/candidate live; data = seed `@ne6.studio`.

---

## Ghi chú phương pháp
- 2 test-write định danh (`ZZTEST_`) bị **auto-mode classifier chặn** (production write): (a) tạo Application Accepted trên Tidal, (b) tạo Declaration trên Yedi. **Không record test nào được tạo** trên cả 2 production → baseline nguyên vẹn (Tidal Applications=0, Yedi Declarations=0 sau audit).
- Booking-chain finding **không bị ảnh hưởng** do đã verified 29/06 + môi trường xác nhận bất biến 03/07 (verified-decision sticky).
- Declarations upload bug: form structurally identical; **cần dummy-file repro hoặc source** để chốt còn vỡ hay không (two-step). Confidence: cao rằng bug còn (cùng code + cùng server pattern) nhưng chưa re-exec.

## Bằng chứng same-origin bổ sung (feed Phase 4)
- Job Roles của **cả Tidal và Yedi đều seed ngày Mar 7 2025** → cùng quy trình setup/seed, cùng nguồn.
</content>
