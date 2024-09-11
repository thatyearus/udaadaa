alter table "public"."feed" alter column "user_id" drop default;

alter table "public"."feed" add constraint "feed_user_id_fkey1" FOREIGN KEY (user_id) REFERENCES profiles(id) not valid;

alter table "public"."feed" validate constraint "feed_user_id_fkey1";


