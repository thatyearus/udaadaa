drop view if exists "public"."random_feed";

create or replace view "public"."random_feed" with (security_invoker=true)
    as SELECT *
   FROM "public"."feed"
  ORDER BY (random());
