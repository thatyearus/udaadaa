alter table "public"."feed" add column "calorie" bigint;

create or replace view "public"."random_feed" as  SELECT *
   FROM feed
  ORDER BY (random());
