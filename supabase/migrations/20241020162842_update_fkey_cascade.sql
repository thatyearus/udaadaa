alter table "public"."feed" drop constraint "feed_user_id_fkey1";

alter table "public"."blocked_feed" drop constraint "blocked_feed_feed_id_fkey";

alter table "public"."blocked_feed" drop constraint "blocked_feed_user_id_fkey";

alter table "public"."reactions" drop constraint "reactions_feed_id_fkey";

alter table "public"."reactions" drop constraint "reactions_user_id_fkey";

alter table "public"."report" drop constraint "report_user_id_fkey";

alter table "public"."feed" add constraint "feed_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."feed" validate constraint "feed_user_id_fkey";

alter table "public"."blocked_feed" add constraint "blocked_feed_feed_id_fkey" FOREIGN KEY (feed_id) REFERENCES feed(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."blocked_feed" validate constraint "blocked_feed_feed_id_fkey";

alter table "public"."blocked_feed" add constraint "blocked_feed_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."blocked_feed" validate constraint "blocked_feed_user_id_fkey";

alter table "public"."reactions" add constraint "reactions_feed_id_fkey" FOREIGN KEY (feed_id) REFERENCES feed(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."reactions" validate constraint "reactions_feed_id_fkey";

alter table "public"."reactions" add constraint "reactions_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."reactions" validate constraint "reactions_user_id_fkey";

alter table "public"."report" add constraint "report_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."report" validate constraint "report_user_id_fkey";


