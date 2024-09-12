drop view if exists "public"."random_feed";

alter table "public"."feed" alter column "type" drop default;

alter type "public"."FeedType" rename to "FeedType__old_version_to_be_dropped";

create type "public"."FeedType" as enum ('breakfast', 'lunch', 'dinner', 'snack', 'exercise', 'weight');

alter table "public"."feed" alter column type type "public"."FeedType" using type::text::"public"."FeedType";

alter table "public"."feed" alter column "type" set default 'breakfast'::"FeedType";

drop type "public"."FeedType__old_version_to_be_dropped";

alter table "public"."feed" alter column "type" set default 'breakfast'::"FeedType";

create or replace view "public"."random_feed" as  SELECT feed.user_id,
    feed.created_at,
    feed.review,
    feed.type,
    feed.image_path,
    feed.id,
    feed.visibility
   FROM feed
  ORDER BY (random());



