# Kế hoạch triển khai

## Nguyên tắc

1. Mã nguồn giao diện và dữ liệu người dùng tách biệt.
2. Không tự động xóa/khởi tạo lại dữ liệu khi cập nhật ứng dụng.
3. Bật RLS cho mọi bảng chứa dữ liệu cá nhân.
4. Không đưa khóa service-role hoặc mật khẩu vào Git.
5. Kiểm thử sao lưu dữ liệu và ảnh trước khi sử dụng chính thức.

## Các giai đoạn

### Giai đoạn 1 — Nền tảng
- [x] Tạo repository.
- [x] Thêm tài liệu khởi đầu.
- [ ] Tạo dự án Supabase.
- [ ] Cấu hình đăng nhập.
- [ ] Tạo bảng và chính sách RLS.

### Giai đoạn 2 — Ứng dụng
- [ ] Tạo giao diện responsive bằng HTML/CSS/JavaScript.
- [ ] Đăng nhập/đăng xuất.
- [ ] CRUD hệ sao và hành tinh.
- [ ] Ghi tọa độ và địa chỉ Glyph.
- [ ] Tải lên và xem ảnh chụp màn hình.
- [ ] Quản lý nhiệm vụ và trạng thái.

### Giai đoạn 3 — Triển khai
- [ ] Kết nối frontend với Supabase bằng URL và publishable/anon key.
- [ ] Xác minh mọi thao tác đều được RLS bảo vệ.
- [ ] Bật GitHub Pages.
- [ ] Kiểm thử trên trình duyệt khác và thiết bị khác.
- [ ] Kiểm thử xuất dữ liệu và sao lưu ảnh.

## Tiêu chí hoàn thành

- Người dùng chưa đăng nhập không đọc/sửa được dữ liệu riêng.
- Người dùng đăng nhập có thể tạo, xem, sửa và xóa bản ghi của mình.
- Ảnh chỉ được truy cập theo chính sách đã định.
- Tải lại trang hoặc cập nhật frontend không làm mất dữ liệu.
- Có quy trình sao lưu và khôi phục đã thử nghiệm.
