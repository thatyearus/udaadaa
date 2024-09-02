create type "public"."FeedType" as enum ('FOOD', 'EXERCISE', 'WEIGHT');

create table "public"."feed" (
    "user_id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone not null default now(),
    "review" text not null,
    "type" "FeedType" not null default 'FOOD'::"FeedType",
    "image_path" text not null,
    "id" uuid not null default gen_random_uuid(),
    "visibility" boolean not null default true
);


alter table "public"."feed" enable row level security;

CREATE UNIQUE INDEX feed_pkey ON public.feed USING btree (id);

alter table "public"."feed" add constraint "feed_pkey" PRIMARY KEY using index "feed_pkey";

alter table "public"."feed" add constraint "feed_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) not valid;

alter table "public"."feed" validate constraint "feed_user_id_fkey";

grant delete on table "public"."feed" to "anon";

grant insert on table "public"."feed" to "anon";

grant references on table "public"."feed" to "anon";

grant select on table "public"."feed" to "anon";

grant trigger on table "public"."feed" to "anon";

grant truncate on table "public"."feed" to "anon";

grant update on table "public"."feed" to "anon";

grant delete on table "public"."feed" to "authenticated";

grant insert on table "public"."feed" to "authenticated";

grant references on table "public"."feed" to "authenticated";

grant select on table "public"."feed" to "authenticated";

grant trigger on table "public"."feed" to "authenticated";

grant truncate on table "public"."feed" to "authenticated";

grant update on table "public"."feed" to "authenticated";

grant delete on table "public"."feed" to "service_role";

grant insert on table "public"."feed" to "service_role";

grant references on table "public"."feed" to "service_role";

grant select on table "public"."feed" to "service_role";

grant trigger on table "public"."feed" to "service_role";

grant truncate on table "public"."feed" to "service_role";

grant update on table "public"."feed" to "service_role";

create policy "Enable delete for users based on user_id"
on "public"."feed"
as permissive
for delete
to public
using ((( SELECT auth.uid() AS uid) = user_id));


create policy "Enable insert for users based on user_id"
on "public"."feed"
as permissive
for insert
to public
with check ((( SELECT auth.uid() AS uid) = user_id));


create policy "Enable read access for all authenticated users"
on "public"."feed"
as permissive
for select
to authenticated
using (true);


create policy "Enable update for users based on user_id"
on "public"."feed"
as permissive
for update
to public
using ((( SELECT auth.uid() AS uid) = user_id));



