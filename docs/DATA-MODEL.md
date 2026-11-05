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

## Bảng `lore_entries`

Cốt truyện (lore) trong game: bản gốc, bản dịch tiếng Việt và ghi chú cá nhân. Một dòng dữ liệu tương ứng một terminal; các dòng chữ của terminal lưu theo thứ tự xuất hiện, ngăn cách bằng xuống dòng.

- `id`: UUID.
- `user_id`: chủ sở hữu.
- `planet_id`: hành tinh liên quan, có thể để trống. Phải là hành tinh của chính chủ sở hữu. Xóa hành tinh thì entry vẫn còn và `planet_id` về trống.
- `title`: tiêu đề ngắn, bắt buộc.
- `iteration_code`: số hiệu Iteration ở đầu terminal, ví dụ `2394829084924924924G`. Là text vì mã trong game lẫn cả chữ và số.
- `original_text`: bản gốc tiếng Anh, bắt buộc.
- `translation_vi`: bản dịch tiếng Việt.
- `source`: nơi tìm thấy, ví dụ `Boundary Failure terminal`.
- `notes`: ghi chú, kể cả phần suy luận về ý nghĩa.
- `created_at`, `updated_at`: thời gian.

### Ví dụ bản ghi

Terminal Boundary Failure có header `ITERATION #2394829084924924924G`. Thứ tự các dòng suy ra từ thứ tự ảnh chụp; ý nghĩa chưa được xác minh.

```sql
insert into public.lore_entries
  (title, iteration_code, original_text, translation_vi, source, notes)
values (
  'Boundary Failure: Vessel [16] emptied',
  '2394829084924924924G',
  'Vessel [16] emptied. Cause: [Sentinel Intervention | Deliberate Transfer]
SCENARIO: Iteration #231187661T [Deleted]. Boundary separation failure likely.
ANALYSIS: Fresh Iteration Generated. Anomaly Containment Prepared.
BROADCAST RECEIVED // TRAVELLER ANOMALY DETECTED //
Anomaly is Compliant. Position logged. System Integrity Scan Initialised.',
  'Khoang chứa (Vessel) [16] đã bị làm trống. Nguyên nhân: [Sentinel can thiệp | Chuyển giao có chủ ý]
KỊCH BẢN: Iteration #231187661T [Đã bị xóa]. Nhiều khả năng xảy ra sự cố tách biệt ranh giới.
PHÂN TÍCH: Đã tạo một Iteration mới. Đã chuẩn bị biện pháp ngăn chặn Anomaly (dị thường).
ĐÃ NHẬN TÍN HIỆU PHÁT // PHÁT HIỆN DỊ THƯỜNG TRAVELLER //
Anomaly tuân thủ. Đã ghi lại vị trí. Đã khởi tạo quét toàn vẹn hệ thống.',
  'Boundary Failure terminal',
  'Thứ tự dòng suy ra từ thứ tự ảnh chụp. Ý nghĩa chưa được xác minh.'
);
```

Ví dụ thứ hai: phần Starship Autodiagnostics ở đầu game, cùng số Iteration với terminal trên. Hai dòng độc thoại cuối có thể xuất hiện ở vị trí khác trong game.

```sql
insert into public.lore_entries
  (title, iteration_code, original_text, translation_vi, source, notes)
values (
  'Starship Autodiagnostics (opening)',
  '2394829084924924924G',
  'ITERATION #2394829084924924924G... ONLINE
ATLAS CONNECTION... INTERMITTENT
Launch Thrusters... OFFLINE
Pulse Engine... OFFLINE
I find myself alone on a strange world, unequipped and in danger. I have no memory of how I got here, no sense of a before.
But this ship at least seems to recognise me. The controls react to my touch, or at least to that of my Exosuit. I am not dead yet, and this ship is a lifeline out to the stars...',
  'ITERATION #2394829084924924924G... HOẠT ĐỘNG
KẾT NỐI ATLAS... CHẬP CHỜN
Launch Thrusters... KHÔNG HOẠT ĐỘNG
Pulse Engine... KHÔNG HOẠT ĐỘNG
Tôi thấy mình đơn độc trên một thế giới xa lạ, không có trang bị và đang gặp nguy hiểm. Tôi không nhớ mình đến đây bằng cách nào, không có chút ý niệm nào về khoảng thời gian trước đó.
Nhưng ít nhất con tàu này dường như nhận ra tôi. Các bộ điều khiển phản ứng với cái chạm của tôi, hay ít nhất là của bộ Exosuit của tôi. Tôi vẫn chưa chết, và con tàu này là sợi dây cứu sinh dẫn ra các vì sao...',
  'Starship Autodiagnostics',
  'Thứ tự dòng suy ra từ thứ tự ảnh chụp; hai dòng độc thoại cuối có thể xuất hiện ở vị trí khác. Sau độc thoại có hai lựa chọn: [1] Read Log, [2] Connect Exosuit. Cùng số Iteration với terminal Boundary Failure.'
);
```

Như bảng `corvette_parts`, `user_id` tự điền bằng `auth.uid()` khi ghi qua client đã đăng nhập; trong Supabase SQL Editor phải truyền `user_id` tường minh.

## Bảo mật

Tất cả bảng cần bật RLS. Chính sách SELECT/INSERT/UPDATE/DELETE phải giới hạn `user_id = auth.uid()`. Storage cần chính sách tương ứng theo đường dẫn và chủ sở hữu. Không xem việc ẩn nút giao diện là biện pháp bảo mật.
