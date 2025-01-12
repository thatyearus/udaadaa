
create or replace function mission_complete(
    user_id uuid,
    review text,
    feed_type "public"."FeedType",
    feed_image_path text,
    calorie integer,
    room_id uuid,
    content text,
    message_image_path text,
    message_type "public"."MessageType"
)
returns uuid as $$
declare
    feed_id uuid;
begin
  insert into feed (user_id, review, type, image_path, calorie, is_challenge)
  values (
    user_id,
    review,
    feed_type,
    feed_image_path,
    calorie,
    true
  )
  returning id into feed_id;

  insert into messages (room_id, user_id, content, image_path, type)
  values (
    room_id,
    user_id,
    content,
    message_image_path,
    message_type
  );

  return feed_id;
end;
$$ language plpgsql security definer;
