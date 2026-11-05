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

## Bảng `corvette_parts`

Danh mục part của Corvette (reactor, tractor beam, ...) kèm giá và nguồn.

- `id`: UUID.
- `user_id`: chủ sở hữu.
- `name`: tên part, ví dụ `Medusa-Class Reactor`. Duy nhất theo từng `user_id`.
- `part_type`: loại part, ví dụ `reactor`, `tractor_beam`. Là text tự do để thêm loại mới không cần migration.
- `part_class`: class/dòng của part, ví dụ `Medusa`.
- `bonus_summary`: mô tả ngắn bonus/chỉ số, ghi tay từ trong game.
- `price_units`: giá bằng Units (số nguyên, không âm), ví dụ `1750000`.
- `source`: nơi mua hoặc nguồn dữ liệu, ví dụ `GTN`, `Corvette Workshop`.
- `notes`: ghi chú tự do.
- `created_at`, `updated_at`: thời gian.

### Ví dụ bản ghi

Số liệu lấy từ màn hình chọn part trong Corvette Workshop (Manoeuvrability +6%, Boost +12%) và giá niêm yết 1,750,000 Units trên GTN.

| Cột | Giá trị |
|---|---|
| `name` | `Medusa-Class Reactor` |
| `part_type` | `reactor` |
| `part_class` | `Medusa` |
| `bonus_summary` | `Manoeuvrability +6%, Boost +12%` |
| `price_units` | `1750000` |
| `source` | `GTN` |

```sql
insert into public.corvette_parts
  (name, part_type, part_class, bonus_summary, price_units, source)
values
  ('Medusa-Class Reactor', 'reactor', 'Medusa',
   'Manoeuvrability +6%, Boost +12%', 1750000, 'GTN');
```

`user_id` tự điền bằng `auth.uid()` khi ghi qua client đã đăng nhập. Trong Supabase SQL Editor không có phiên đăng nhập, nên phải truyền `user_id` tường minh.

## Bảo mật

Tất cả bảng cần bật RLS. Chính sách SELECT/INSERT/UPDATE/DELETE phải giới hạn `user_id = auth.uid()`. Storage cần chính sách tương ứng theo đường dẫn và chủ sở hữu. Không xem việc ẩn nút giao diện là biện pháp bảo mật.
