# Cấu hình Supabase

## Tạo dự án

1. Mở https://supabase.com/dashboard và đăng nhập.
2. Tạo một project mới riêng cho NMS Planet Notebook.
3. Lưu an toàn thông tin đăng nhập và thông tin kết nối.
4. Không gửi mật khẩu hoặc secret key qua chat.

## Trước khi nối frontend

- Tạo schema theo `DATA-MODEL.md`.
- Bật RLS trên mọi bảng.
- Viết chính sách cho người dùng chỉ truy cập bản ghi của chính họ.
- Tạo Storage bucket riêng cho ảnh, mặc định private.
- Viết chính sách Storage giới hạn đọc/ghi theo chủ sở hữu.
- Kiểm tra bằng tài khoản đăng nhập và phiên chưa đăng nhập.

## Khóa dùng ở frontend

Frontend tĩnh có thể sử dụng Project URL cùng publishable key (hoặc anon key legacy), nhưng chỉ sau khi RLS và chính sách Storage đã được cấu hình, kiểm thử. Không bao giờ đặt service-role/secret key trong HTML, JavaScript phía trình duyệt, GitHub repository hoặc GitHub Pages.

## Sao lưu

Xuất dữ liệu định kỳ. Sao lưu database không mặc nhiên sao lưu các tệp ảnh trong Storage; cần tải ảnh hoặc duy trì bản sao riêng và kiểm tra khả năng khôi phục.
