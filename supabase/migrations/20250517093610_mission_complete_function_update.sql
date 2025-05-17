create or replace function mission_complete(
    user_id uuid,
    review text,
    feed_type "public"."FeedType",
    feed_image_path text,
    calorie integer,
    room_id uuid,
    content text,
    message_image_path text,
    message_type "public"."MessageType",
    weight float,
    weight_date date 
)
returns uuid as $$
declare
    feed_id uuid;
begin
  if feed_type = 'weight' then
    insert into weight (user_id, weight, date, image_path)
    values (
      user_id,
      weight,
      weight_date,
      feed_image_path
    )
    returning id into feed_id;
  else
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
  end if;

  insert into messages (room_id, user_id, content, image_path, type)
  values (
    room_id,
    user_id,
    content,
    message_image_path,
    message_type
  );

  if feed_type <> 'weight' and review is not null and trim(review) <> '' then
    perform pg_sleep(0.1);
    
    insert into messages (room_id, user_id, content, image_path, type)
    values (
      room_id,
      user_id,
      review,
      null,
      'textMessage'::"public"."MessageType"
    );
  end if;

  return feed_id;
end;
$$ language plpgsql security definer;
