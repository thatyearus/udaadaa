create table "public"."blocked_feed" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone not null default now(),
    "feed_id" uuid,
    "user_id" uuid not null
);


alter table "public"."blocked_feed" enable row level security;

CREATE UNIQUE INDEX blocked_feed_pkey ON public.blocked_feed USING btree (id);

alter table "public"."blocked_feed" add constraint "blocked_feed_pkey" PRIMARY KEY using index "blocked_feed_pkey";

alter table "public"."blocked_feed" add constraint "blocked_feed_feed_id_fkey" FOREIGN KEY (feed_id) REFERENCES feed(id) ON DELETE CASCADE not valid;

alter table "public"."blocked_feed" validate constraint "blocked_feed_feed_id_fkey";

alter table "public"."blocked_feed" add constraint "blocked_feed_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE not valid;

alter table "public"."blocked_feed" validate constraint "blocked_feed_user_id_fkey";

grant delete on table "public"."blocked_feed" to "anon";

grant insert on table "public"."blocked_feed" to "anon";

grant references on table "public"."blocked_feed" to "anon";

grant select on table "public"."blocked_feed" to "anon";

grant trigger on table "public"."blocked_feed" to "anon";

grant truncate on table "public"."blocked_feed" to "anon";

grant update on table "public"."blocked_feed" to "anon";

grant delete on table "public"."blocked_feed" to "authenticated";

grant insert on table "public"."blocked_feed" to "authenticated";

grant references on table "public"."blocked_feed" to "authenticated";

grant select on table "public"."blocked_feed" to "authenticated";

grant trigger on table "public"."blocked_feed" to "authenticated";

grant truncate on table "public"."blocked_feed" to "authenticated";

grant update on table "public"."blocked_feed" to "authenticated";

grant delete on table "public"."blocked_feed" to "service_role";

grant insert on table "public"."blocked_feed" to "service_role";

grant references on table "public"."blocked_feed" to "service_role";

grant select on table "public"."blocked_feed" to "service_role";

grant trigger on table "public"."blocked_feed" to "service_role";

grant truncate on table "public"."blocked_feed" to "service_role";

grant update on table "public"."blocked_feed" to "service_role";

create policy "Enable delete for users based on user_id"
on "public"."blocked_feed"
as permissive
for delete
to public
using ((( SELECT auth.uid() AS uid) = user_id));


create policy "Enable insert for users based on user_id"
on "public"."blocked_feed"
as permissive
for insert
to public
with check ((( SELECT auth.uid() AS uid) = user_id));


create policy "Enable select for users based on user_id"
on "public"."blocked_feed"
as permissive
for select
to public
using ((( SELECT auth.uid() AS uid) = user_id));


create policy "Enable update for users based on user_id"
on "public"."blocked_feed"
as permissive
for update
to public
using ((( SELECT auth.uid() AS uid) = user_id));



