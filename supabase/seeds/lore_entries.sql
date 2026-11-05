-- Seed: lore_entries
--
-- Loads two lore entries into public.lore_entries for ONE existing account:
--   1. Boundary Failure terminal ("Vessel [16] emptied", 5 lines)
--   2. Opening Starship Autodiagnostics (6 lines)
-- The original text is quoted from in-game screenshots. The Vietnamese
-- translation, the line order and the notes are reconstructed from those
-- screenshots; their meaning has not been verified against official sources.
--
-- HOW TO USE (Supabase Dashboard > SQL Editor, after schema.sql was applied):
--   1. Create the login account first (Authentication > Users).
--   2. Paste this script into the SQL Editor and replace REPLACE_WITH_YOUR_LOGIN_EMAIL
--      below with that account's email. Do NOT commit your real email to Git.
--   3. Run it. If no account matches, the script stops with an error instead of
--      inserting nothing. Running it again does not create duplicates (entries
--      are matched by owner + title).
--
-- The SQL Editor has no logged-in user (auth.uid() is NULL), so the owner is
-- looked up in auth.users by email and written to user_id explicitly.

do $$
declare
  owner_email constant text := 'REPLACE_WITH_YOUR_LOGIN_EMAIL';
  owner_id uuid;
  inserted_count integer;
begin
  select id into owner_id from auth.users where lower(email) = lower(owner_email);
  if owner_id is null then
    raise exception 'No auth.users row with email %. Create the account first and set owner_email at the top of this script.', owner_email;
  end if;

  insert into public.lore_entries
    (user_id, title, iteration_code, original_text, translation_vi, source, notes)
  select owner_id, v.title, v.iteration_code, v.original_text, v.translation_vi, v.source, v.notes
  from (values
    (
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
    ),
    (
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
    )
  ) as v(title, iteration_code, original_text, translation_vi, source, notes)
  where not exists (
    select 1 from public.lore_entries e
    where e.user_id = owner_id and e.title = v.title
  );

  get diagnostics inserted_count = row_count;
  raise notice 'lore_entries seed: % new entries inserted for % (existing entries are left unchanged).',
    inserted_count, owner_email;
end
$$;
