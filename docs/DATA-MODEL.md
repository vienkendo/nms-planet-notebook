# Thiết kế dữ liệu ban đầu

Schema sẽ được triển khai trong Supabase PostgreSQL. Đây là thiết kế dự kiến, cần được tạo và kiểm tra trước khi frontend sử dụng.

## Bảng `star_systems`

- `id`: UUID, khóa chính.
- `user_id`: UUID, liên kết tài khoản Auth.
- `name`: tên hệ sao.
- `galaxy`: thiên hà.
- `system_coordinates`: tọa độ hoặc chuỗi định vị trong game.
- `portal_glyphs`: địa chỉ Glyph nếu có.
- `notes`: ghi chú.
- `created_at`, `updated_at`: thời gian.

## Bảng `planets`

- `id`: UUID, khóa chính.
- `user_id`: UUID, chủ sở hữu.
- `system_id`: hệ sao liên quan, có thể để trống.
- `name`: tên hành tinh.
- `planet_type`: loại hành tinh.
- `weather`, `sentinels`, `flora`, `fauna`, `resources`: mô tả khám phá.
- `planet_coordinates`: tọa độ.
- `discovery_status`: trạng thái khám phá.
- `notes`: ghi chú tự do.
- `created_at`, `updated_at`: thời gian.

## Bảng `planet_images`

- `id`: UUID.
- `user_id`: chủ sở hữu.
- `planet_id`: hành tinh liên quan.
- `storage_path`: đường dẫn đối tượng trong Storage.
- `caption`: chú thích.
- `created_at`: thời gian.

## Bảng `missions`

- `id`: UUID.
- `user_id`: chủ sở hữu.
- `title`: tên/mục tiêu nhiệm vụ.
- `status`: chưa làm, đang làm, hoàn thành hoặc tạm dừng.
- `planet_id`: hành tinh liên quan, có thể để trống.
- `notes`: ghi chú.
- `created_at`, `updated_at`: thời gian.

## Bảo mật

Tất cả bảng cần bật RLS. Chính sách SELECT/INSERT/UPDATE/DELETE phải giới hạn `user_id = auth.uid()`. Storage cần chính sách tương ứng theo đường dẫn và chủ sở hữu. Không xem việc ẩn nút giao diện là biện pháp bảo mật.
