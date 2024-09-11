create or replace view "public"."random_feed" as  SELECT feed.user_id,
    feed.created_at,
    feed.review,
    feed.type,
    feed.image_path,
    feed.id,
    feed.visibility
   FROM feed
  ORDER BY (random());



