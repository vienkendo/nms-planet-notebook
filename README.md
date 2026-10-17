# Sổ tay hành tinh No Man's Sky

Ứng dụng cá nhân để lưu thông tin hành tinh, hệ sao, tọa độ, địa chỉ Glyph, ảnh chụp màn hình và tiến độ nhiệm vụ.

## Mục tiêu

- Lưu dữ liệu trực tuyến để sử dụng trên nhiều thiết bị.
- Đăng nhập để bảo vệ dữ liệu.
- Cập nhật giao diện/mã nguồn mà không xóa dữ liệu đã lưu.
- Hỗ trợ sao lưu dữ liệu định kỳ.

## Kiến trúc dự kiến

- **Frontend:** HTML/CSS/JavaScript tĩnh, triển khai bằng GitHub Pages.
- **Backend dữ liệu:** Supabase Auth, PostgreSQL và Storage.
- **Bảo mật:** Bật Row Level Security (RLS) cho các bảng và thiết lập chính sách Storage để chỉ tài khoản được phép truy cập dữ liệu.
- **Bí mật:** Không đưa khóa service-role hoặc bí mật vào mã frontend hay repository.

## Trạng thái triển khai

- [x] Tạo repository riêng.
- [x] Khởi tạo tài liệu dự án.
- [ ] Tạo dự án Supabase mới.
- [ ] Tạo schema và bật RLS.
- [ ] Kết nối đăng nhập và dữ liệu.
- [ ] Tạo giao diện sổ tay.
- [ ] Triển khai GitHub Pages.
- [ ] Kiểm tra lưu, sửa, đăng xuất/đăng nhập và sao lưu.

## Dữ liệu dự kiến

- Hệ sao: tên, tọa độ thiên hà, ghi chú.
- Hành tinh: tên, loại môi trường, tài nguyên, thời tiết, sentinels, mức độ khám phá.
- Định vị: tọa độ, địa chỉ Glyph và ghi chú cổng dịch chuyển.
- Hình ảnh: ảnh chụp màn hình gắn với hệ sao/hành tinh.
- Nhiệm vụ: trạng thái, mục tiêu và hành tinh liên quan.

## Lưu ý sao lưu

Sao lưu cơ sở dữ liệu không nhất thiết bao gồm các tệp trong Storage; ảnh cần có quy trình sao lưu riêng. Trước khi dùng thực tế, cần kiểm thử xuất/nhập dữ liệu và ảnh. Các bản cập nhật giao diện không được tự động xóa hay khởi tạo lại dữ liệu người dùng.

## Tài liệu

- [Kế hoạch triển khai](docs/IMPLEMENTATION-PLAN.md)
- [Thiết kế dữ liệu](docs/DATA-MODEL.md)
- [Hướng dẫn cấu hình Supabase](docs/SUPABASE-SETUP.md)
