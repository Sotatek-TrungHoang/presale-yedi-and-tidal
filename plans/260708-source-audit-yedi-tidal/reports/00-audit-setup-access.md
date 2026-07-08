# 00 — Setup môi trường + access (Phase 0 gate)

> Source audit Yedi+Tidal · 2026-07-08 · nội bộ Sotatek. Ghi lại môi trường dựng được tới đâu → giới hạn dynamic của các phase sau.

## Tooling máy audit
| Tool | Version | Ghi chú |
|---|---|---|
| Docker | 29.3.1, daemon RUNNING | dùng chạy Sail + bootstrap composer |
| PHP (local) | 8.4.13 | chỉ hỗ trợ IDE; Sail dùng PHP trong container |
| composer (local) | **KHÔNG có** | bootstrap deps qua image `laravelsail/php83-composer` |
| Flutter | 3.41.9 stable | |

## API — `source/yedi-tidal-api`
- **Deps:** thiếu ban đầu → cài qua `docker run laravelsail/php83-composer composer install --ignore-platform-reqs` (exit 0).
- **`.env`:** **repo KHÔNG có `.env` lẫn `.env.example`** — nhưng `docs/deployment-guide.md:19` hướng dẫn `cp .env.example .env`. → **Finding (🟡, reliability): thiếu env template**, dev mới không có mẫu, phải tự dựng. Đã self-author `.env` local từ **Sail defaults + checklist `deployment-guide.md:78-169`**: core (`APP_KEY` generate, `APP_CONFIGURATION=yedi`), DB/Redis/Mail = Sail (`mysql`/`redis`/`mailpit`), `FILESYSTEM_DISK=local`, `QUEUE_CONNECTION=sync`, **external service để trống/stub** (DocGen/Maps/Firebase/Sentry) → boot không cần secret thật. **Không commit.**
- **Sail bring-up:** `docker compose up -d --build` (runtime 8.4) → `key:generate` → `migrate` → `db:seed`. *(Kết quả migrate/seed: xem cuối file — cập nhật sau khi build container xong; static schema audit ở report 05 không phụ thuộc bước này.)*
- **`DB_CONNECTION` default:** report 05 phát hiện default trong `config/database.php` = **sqlite** (không phải mysql) — cần xác nhận prod set mysql. Local audit ép `mysql` qua `.env`.

## App — `source/yedi-tidal-app`
- **Deps:** `flutter pub get` (exit 0).
- **`.env.yedi`/`.env.tidal`:** **đã commit** (chỉ `BASE_API_URL` + `GOOGLE_MAPS_API_KEY`) → chạy out-of-box. Mặc định `BASE_API_URL` trỏ **prod** (`admin.yedi.group`) → khi test dynamic phải repoint sang local để tránh đụng prod.
- **`flutter analyze`:** **3 issue, toàn `info`-level** (deprecation `value`/`color` ở `dropdown_input.dart:34`, `tidal_theme.dart:52`, `yedi_theme.dart:50`) — **0 error/warning**, app analyze sạch.
- **`./scripts/pre_yedi.sh`:** **FAIL** ở bước flutterfire: `scripts/flutterfire_config_yedi.sh:2` hardcode `/Users/matt/.pub-cache/bin/flutterfire` (đường dẫn máy dev gốc "matt") → **Finding (🟠, mobile/build): script chuẩn-bị-flavor không portable**, vỡ trên mọi máy khác + CI. `flutter analyze` vẫn chạy được vì `lib/firebase_options.dart` đã commit sẵn. Ảnh hưởng: onboard dev mới + CI/CD build tự động sẽ fail regen Firebase config.

## Access hiện có / còn thiếu
- ✅ Source đầy đủ 2 repo.
- ✅ Live admin creds `client/credentials.txt` (Yedi + Tidal `/admin`) — chưa exercise trong session này (dùng khi cần confirm hành vi cụ thể).
- 🔴 **Read-only prod DB:** CHƯA có → Phase 5 data-volume + migrate-state prod = **inference**, cần xin để chốt.
- 🔴 **DocGen + Firebase creds thật:** CHƯA → Phase 2 (sinh invoice/payslip live) + Phase 7 (push FCM) = static-only cho đúng pipeline đó. Boot local **không** cần chúng (đã validate).

## Giới hạn dynamic (ảnh hưởng confidence)
| Kiểm | Chạy được local? | Ghi chú |
|---|---|---|
| Boot API + Filament `/admin` | ✅ | Sail đầy đủ |
| `migrate` sạch (49 migration) | ✅ (pending confirm) | xác nhận schema dựng từ 0 |
| Charge/rate math (tinker) | ✅ | pure accessor `Advert.php` — verify được không cần external |
| App analyze/build | ✅ | analyze sạch; build cần fix pre-script |
| Sinh invoice/payslip PDF (DocGen) | ❌ | cần DocGen creds → static-only |
| Push FCM end-to-end | ❌ | cần Firebase creds → static-only |
| Data volume + migrate state PROD | ❌ | cần read-only prod DB |

---
### Kết quả Sail bring-up (dynamic — đã chạy)
- **Containers:** `mysql`/`redis`/`mailpit`/`laravel.test` up (MySQL healthy ~15s).
- **⚠️ Onboarding gap (🟠):** clone thiếu **`bootstrap/cache`** và **`storage/framework/{cache,sessions,views}`** → artisan fail `"bootstrap/cache must be present and writable"`; phải `mkdir` thủ công. Kèm **thiếu `.env`/`.env.example`** + **pre-script hardcode path "matt"** → **3 rào onboarding**: một dev/CI mới KHÔNG boot được từ clone nếu không có tài liệu ngầm. (Ảnh hưởng trực tiếp velocity + CI setup.)
- **`key:generate`:** ✅ OK sau khi tạo dir.
- **`migrate:fresh` (MySQL 8):** ✅ **49/49 migration CLEAN** — kể cả cặp trùng-timestamp `2025_01_24_093814` invoices+payslips (chạy tuần tự OK) + `fix_invoice_items_quantity_column` + `convert_application_actioned_at_to_date_time`. → xác nhận schema dựng-từ-0 không vỡ (report 05 static + dynamic khớp).
- **`db:seed`:** ✅ chạy (seed tối thiểu).
- **Verify schema/logic dynamic:** `users` có 21 cột gồm **`is_super_admin`**; admin-gate `User.php:104-106` = `type===Admin && is_super_admin` — **xác nhận claim security report 01** (không phải RBAC granular). *(Lưu ý: probe đầu dùng nhầm tên `super_admin` → column thật là `is_super_admin`; không phải bug code.)*
- **Live admin + prod DB + DocGen/Firebase creds:** vẫn chưa exercise (xem Open Questions report 08).

**Kết luận Phase 0:** môi trường local boot + migrate + seed **thành công**; codebase **runnable** (tín hiệu reusability tốt). Giới hạn còn lại: external-flow (DocGen/FCM live) + prod DB — không block audit static (đã xong 7 domain).
