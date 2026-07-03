# Phân tích Tidal Agency Admin Panel

## Đây là gì?

Đây là **bảng quản trị (admin panel) của Tidal Agency** — một công ty/nền tảng làm về **tuyển dụng & cung ứng nhân sự cho ngành bán lẻ cao cấp (luxury retail staffing / recruitment agency)**. Hệ thống có vẻ được xây trên framework Filament (Laravel admin), với giao diện gồm sidebar trái và các module dạng list/CRUD.

## Mô hình kinh doanh (Business Model)

Bản chất đây là một **agency môi giới nhân sự hai chiều (two-sided marketplace)**, kết nối giữa **Brands (thương hiệu cần thuê người)** và **Candidates (ứng viên/nhân sự)**. Điểm xác nhận rõ nhất nằm ở mục "Payment & Charges" của một advert:

- **Brand Pay Rate**: GBP 150.00 / ngày (Daily) — mức tiền thương hiệu trả.
- **Brand Charge %**: 15 — phí Tidal thu từ phía thương hiệu.
- **Candidate Charge %**: 5 — phí Tidal thu từ phía ứng viên.

Nghĩa là Tidal kiếm tiền bằng cách **ăn hoa hồng/phí hai đầu** trên mỗi giao dịch tuyển dụng: thu phần trăm từ brand và phần trăm từ candidate. Khách hàng thực tế là các thương hiệu lớn như **Kering** (tập đoàn xa xỉ) và **Creed / The House of Creed** (nước hoa cao cấp), với vị trí ví dụ "Luxury Brand Ambassador" tại Bicester Village.

Hệ thống hỗ trợ 3 loại hình công việc (Types of Work): **việc tạm thời ngắn hạn, việc tạm thời dài hạn, và việc cố định (permanent)** — cho thấy họ làm cả staffing tạm thời lẫn tuyển dụng chính thức.

## Các nghiệp vụ hiện có

Luồng nghiệp vụ chính: Brand đăng tin → tạo Advert → Candidate ứng tuyển tạo Application → khớp việc → xuất Invoice (cho brand) và Payslip (cho candidate).

### Brands (Thương hiệu)
Quản lý các thương hiệu khách hàng, mỗi brand có trạng thái tuân thủ (Compliant / Non Compliant / Pending / Incomplete), số lượng adverts, thông tin liên hệ và ngày tham gia. Hiện có Creed và Kering.

### Adverts (Tin tuyển dụng)
Quản lý các vị trí công việc với phân loại theo type (Day to day / Long term) và trạng thái (Approved, Filled, Not filled, Pending allocation, Pending approval, Rejected). Mỗi advert có mô tả chi tiết, địa điểm, ngày bắt đầu/kết thúc, ca làm, hạn nộp và phần cấu hình giá/phí.

### Candidates (Ứng viên)
Quản lý nhân sự với trạng thái compliance và thống kê (Accepted / Cancelled / Declined / Pending), gắn job role và type of work. Đây là module có dữ liệu nhiều nhất (~10 ứng viên), nhiều người ở trạng thái "Incomplete" hoặc "Pending Approval".

### Applications (Đơn ứng tuyển)
Luồng khớp candidate với advert (hiện chưa có dữ liệu).

### Invoices & Payslips
Nghiệp vụ tài chính: hóa đơn xuất cho brand và phiếu lương cho candidate (cả hai hiện trống).

### Settings
Các cấu hình nền: **Job Roles** (vai trò công việc), **Required Evidence** (bằng chứng/giấy tờ ứng viên cần nộp — phục vụ compliance/right-to-work), **Types of Work**, **Declarations** (cam kết/khai báo), và **System**.

### Admin > Users
Quản lý tài khoản nội bộ (hiện có 1 admin: Jay Mihcioglu).

## Điểm nổi bật về nghiệp vụ

**Tính tuân thủ (compliance)** rất được nhấn mạnh — xuất hiện ở cả Brands và Candidates, kết hợp với module "Required Evidence" và "Declarations". Điều này phù hợp với đặc thù staffing tại UK, nơi cần kiểm tra quyền làm việc và giấy tờ trước khi cho phép một ứng viên được "Compliant" và đủ điều kiện nhận việc.
