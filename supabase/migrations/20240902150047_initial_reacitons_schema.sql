create type "public"."ReactionType" as enum ('GOOD', 'CHEERUP', 'HMMM', 'NOPE', 'AWESOME');

create table "public"."reactions" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone not null default now(),
    "user_id" uuid not null,
    "feed_id" uuid not null default gen_random_uuid(),
    "type" "ReactionType" not null
);


alter table "public"."reactions" enable row level security;

CREATE UNIQUE INDEX reactions_pkey ON public.reactions USING btree (id);

alter table "public"."reactions" add constraint "reactions_pkey" PRIMARY KEY using index "reactions_pkey";

alter table "public"."reactions" add constraint "reactions_feed_id_fkey" FOREIGN KEY (feed_id) REFERENCES feed(id) ON DELETE CASCADE not valid;

alter table "public"."reactions" validate constraint "reactions_feed_id_fkey";

alter table "public"."reactions" add constraint "reactions_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE not valid;

alter table "public"."reactions" validate constraint "reactions_user_id_fkey";

grant delete on table "public"."reactions" to "anon";

grant insert on table "public"."reactions" to "anon";

grant references on table "public"."reactions" to "anon";

grant select on table "public"."reactions" to "anon";

grant trigger on table "public"."reactions" to "anon";

grant truncate on table "public"."reactions" to "anon";

grant update on table "public"."reactions" to "anon";

grant delete on table "public"."reactions" to "authenticated";

grant insert on table "public"."reactions" to "authenticated";

grant references on table "public"."reactions" to "authenticated";

grant select on table "public"."reactions" to "authenticated";

grant trigger on table "public"."reactions" to "authenticated";

grant truncate on table "public"."reactions" to "authenticated";

grant update on table "public"."reactions" to "authenticated";

grant delete on table "public"."reactions" to "service_role";

grant insert on table "public"."reactions" to "service_role";

grant references on table "public"."reactions" to "service_role";

grant select on table "public"."reactions" to "service_role";

grant trigger on table "public"."reactions" to "service_role";

grant truncate on table "public"."reactions" to "service_role";

grant update on table "public"."reactions" to "service_role";

create policy "Enable delete for users based on user_id"
on "public"."reactions"
as permissive
for delete
to public
using ((( SELECT auth.uid() AS uid) = user_id));


create policy "Enable insert for users based on user_id"
on "public"."reactions"
as permissive
for insert
to public
with check ((( SELECT auth.uid() AS uid) = user_id));


create policy "Enable read access for all authenticated users"
on "public"."reactions"
as permissive
for select
to authenticated
using (true);


create policy "Enable update for users based on user_id"
on "public"."reactions"
as permissive
for update
to public
using ((( SELECT auth.uid() AS uid) = user_id));



