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

## Kiểm tra schema tự động (CI)

Workflow `.github/workflows/schema.yml` chạy khi `supabase/**` thay đổi. Nó áp dụng `supabase/schema.sql` hai lần (kiểm tra idempotent) lên một PostgreSQL 16 tạm, rồi chạy các test trong `supabase/tests/`. Supabase được giả lập bằng `supabase/tests/stub_supabase.sql`, nên CI bắt được lỗi SQL, mất idempotent và lỗi RLS/constraint, nhưng không thay thế việc thử trên project Supabase thật.

Chạy thử trên máy có PostgreSQL (dùng một database tạm, không bao giờ chạy stub trên project Supabase thật):

```bash
createdb nmstest
psql -X -v ON_ERROR_STOP=1 -d nmstest -f supabase/tests/stub_supabase.sql
psql -X -v ON_ERROR_STOP=1 -d nmstest -f supabase/schema.sql
psql -X -v ON_ERROR_STOP=1 -d nmstest -f supabase/tests/corvette_parts.test.sql
psql -X -v ON_ERROR_STOP=1 -d nmstest -f supabase/tests/lore_entries.test.sql
```

## Sao lưu

Xuất dữ liệu định kỳ. Sao lưu database không mặc nhiên sao lưu các tệp ảnh trong Storage; cần tải ảnh hoặc duy trì bản sao riêng và kiểm tra khả năng khôi phục.
