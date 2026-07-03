# Tóm tắt Client Brief — Yedi & Tidal (bản tiếng Việt)

> Nguồn: `client/Tidal.docx` — email brief từ khách hàng gửi cho team dev/agency, mô tả bối cảnh và phạm vi dự định của 2 nền tảng staffing (tuyển dụng/bố trí nhân sự): **Yedi** và **Tidal**.

---

## Bối cảnh

- Khách hàng đang chờ team review bản build hiện tại; email này cung cấp **background đầy đủ** về ý định ban đầu của 2 nền tảng (trích từ chat năm 2024 khi phần lớn công việc đang triển khai).
- Cả 2 nền tảng xuất phát từ cùng một ý tưởng cốt lõi: **giảm quy trình thủ công** trong staffing (bố trí nhân sự, xếp lịch, tuân thủ/compliance, chấm công, giao tiếp).
- Không phải job board đơn thuần mà là một **"operational layer" (lớp vận hành)** cho staffing: quản lý hồ sơ, compliance, availability, matching, booking, phê duyệt, timesheet, giao tiếp, hiển thị thanh toán và báo cáo.
- Mục tiêu là gom giao tiếp từ WhatsApp, spreadsheet, email rời rạc về **một hệ thống duy nhất**, đồng thời tăng khả năng hiển thị (visibility) khi doanh nghiệp scale.

## 2 nền tảng

| | **Yedi** | **Tidal** |
|---|---|---|
| Ngành | Education staffing (giáo dục) | Beauty, retail & experiential staffing (làm đẹp, bán lẻ, sự kiện) |
| Kết nối | Trường học ↔ giáo viên, trợ giảng, SEMH support, admin, business manager | Brand/retailer/agency ↔ beauty advisor, MUA, tư vấn nước hoa, retail associate, brand ambassador, event staff |
| Đặc thù | **Compliance mạnh** (DBS, safeguarding, references) — vì liên quan bảo vệ trẻ em | Talent pool theo city/brand; định hướng thành **"Tidal OS"** — workforce operating system (không chỉ app đặt nhân sự) |

---

## Chức năng cốt lõi chung (3 phía)

### 1. Candidate / Worker (ứng viên/nhân sự)
Đăng ký tài khoản; xây & sửa hồ sơ; upload tài liệu; thêm kinh nghiệm, kỹ năng, role preferences, địa điểm; đặt availability; xem cơ hội; apply/accept shift; nhận xác nhận booking; xem lịch sắp tới; nộp timesheet; theo dõi trạng thái duyệt/thanh toán; nhận thông báo; nhận feedback/rating; truy cập training/onboarding; referral (giới thiệu ứng viên khác).

> Hồ sơ phải là **"live worker record"** (bản ghi nhân sự sống), không phải form đăng ký một lần.
> - Tidal: hồ sơ gồm beauty, retail, fragrance, skincare, luxury retail, events, brand experience.
> - Yedi: hồ sơ gồm chi tiết đặc thù giáo dục — kinh nghiệm giảng dạy, DBS, safeguarding, qualifications, references, môi trường trường học ưa thích.

### 2. Client / School (khách hàng/trường học)
Đăng ký tài khoản; gửi yêu cầu nhân sự; chọn role type, địa điểm, ngày/giờ/yêu cầu shift; thêm ghi chú/yêu cầu đặc biệt; xem candidate được gợi ý; duyệt/xác nhận booking; xem booking sắp tới; theo dõi attendance; duyệt timesheet; để lại feedback; xem invoice/booking summary; báo cáo cơ bản.

> - Yedi: client thường là trường học, trust hoặc cơ sở giáo dục.
> - Tidal: client có thể là beauty brand, retailer, agency, event organiser, head office, concession manager, regional manager.

### 3. Admin / Internal team (đội nội bộ — **phần quan trọng nhất**)
Xem tất cả candidate; duyệt/từ chối đăng ký; verify tài liệu; track compliance; tạo & quản lý booking; gán candidate vào shift; **override matching thủ công**; xem availability; quản lý account client/school; quản lý timesheet (duyệt/từ chối/query); track booking status; gửi thông báo; quản lý huỷ/no-show; track feedback 2 chiều; tạo báo cáo; export data; quản lý region, role, rate, location.

> Admin cần **toàn quyền kiểm soát**. Kể cả khi matching tự động hơn theo thời gian, vẫn cần giám sát của con người vì staffing dựa trên quan hệ và nhạy cảm về chất lượng.

---

## Matching logic

**Chung**: location, availability, role type, kinh nghiệm, compliance status, distance.

- **Yedi thêm**: DBS status, qualifications, preferred age group, preferred school type, previous bookings, feedback/rating, reliability.
- **Tidal thêm**: brand experience, retailer experience, category experience (beauty/fragrance/skincare), language skills, past performance, client preference, training completed, rate expectations.
  - *Ví dụ*: brand nước hoa cao cấp cần cover ở Selfridges/Boots → hệ thống gợi ý người có kinh nghiệm fragrance + retail + đúng địa điểm.

> Matching tự động hữu ích, nhưng vẫn cần admin duyệt/chỉnh trước khi chốt.

### Compliance (đặc biệt với Yedi)
Yedi cần lớp compliance mạnh hơn Tidal vì liên quan safeguarding. Hệ thống cần track: DBS status & ngày hết hạn/gia hạn, right to work, ID documents, references, qualifications, safeguarding training, employment history, document expiry dates, approval status, internal notes, compliance warnings.

> Hệ thống nên **flag tài liệu thiếu/hết hạn** trước khi ai đó được book vào trường.

### Tidal — Client visibility
Mục tiêu lớn: cho client thấy nhiều hơn agency truyền thống — upcoming bookings, confirmed staff, role coverage, shift status, attendance, timesheet status, feedback, performance summaries, fill rates, regional coverage, spend/booking summaries, staff ratings.

> Tidal không bán "người" — mà bán **độ tin cậy, khả năng hiển thị và trải nghiệm staffing tốt hơn**.

---

## Các workflow chính

1. **Registration**: candidate đăng ký → điền hồ sơ → upload tài liệu → admin review → duyệt/từ chối/yêu cầu thêm → được match/book.
2. **Client booking**: client gửi request → hệ thống ghi nhận role/location/date/time/rate/yêu cầu → gợi ý candidate → admin duyệt & xác nhận → candidate được thông báo → accept/decline → chốt booking → client xem status.
3. **Timesheet**: candidate xong shift → nộp timesheet → client/school duyệt/query → admin review → trigger/export thanh toán/invoice → status hiển thị.
4. **Compliance**: candidate upload tài liệu → admin verify → lưu ngày hết hạn → flag hết hạn/thiếu → candidate non-compliant không thể book (nơi bắt buộc).
5. **Feedback**: sau booking client/school để lại feedback → track reliability & quality → admin dùng cho matching sau → xây lớp chất lượng theo thời gian.

---

## Lộ trình sản phẩm

### MVP (ưu tiên các thiết yếu vận hành)
Đăng ký candidate + client/school; admin dashboard; quản lý hồ sơ; upload tài liệu; availability; tạo booking; gán candidate; xác nhận booking; timesheet; notification cơ bản; compliance status cơ bản; reporting/export cơ bản.

### Phase 2
Automated matching; reporting nâng cao; ratings/reviews; referral programme; in-app training; worker rewards; client dashboard; payment tracking; payroll/invoicing integration; calendar integration; talent pool nâng cao; regional performance dashboard.

### Future / Advanced
AI-assisted matching; dự báo nhu cầu staffing; candidate performance scoring; nhắc compliance tự động; client self-serve booking; dynamic rate management; payroll/invoice tự động; mobile app; workforce analytics sâu.

---

## Điểm chiến lược

- Front-end phải **đơn giản**, back-end phải **mạnh mẽ**.
  - Candidate: đăng ký → upload tài liệu → set availability → accept work → nộp timesheet.
  - Client: request staff → confirm booking → duyệt timesheet → xem status.
  - Nội bộ: compliance, matching, admin control, reporting, payment visibility, performance tracking, giám sát vận hành.
- **Sai lầm cần tránh**: xây thành marketplace thuần túy. Mục tiêu không phải loại bỏ quan hệ con người khỏi staffing, mà **hỗ trợ, tổ chức và giúp nó scalable hơn**.

---

## Khách hàng muốn gì từ team (Deliverables)

Sau khi review build hiện tại, khách hàng muốn nhận:

- Đánh giá hiện trạng nền tảng: cái gì **dùng được** / cần **fix** / cần **rebuild**
- **Rủi ro kỹ thuật**
- **Con đường nhanh nhất tới MVP ổn định**
- **Product roadmap** đề xuất
- **Ước tính thời gian & chi phí**
- Đề xuất cấu trúc tốt hơn cho cả 2 nền tảng
- **Quyết định chiến lược quan trọng**: Yedi & Tidal nên là **2 sản phẩm tách rời** hay **chung backend + front-end riêng theo ngành**?
  - Bản năng khách hàng nghiêng về **shared infrastructure**, nhưng branding, workflow và compliance phải **riêng biệt cho từng ngành**.

> Khách hàng sẵn sàng jump on a call để trao đổi chi tiết.
