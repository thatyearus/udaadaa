create table "public"."blocked_users" (
    "created_at" timestamp with time zone not null default now(),
    "user_id" uuid not null default gen_random_uuid(),
    "block_user_id" uuid not null default gen_random_uuid()
);


alter table "public"."blocked_users" enable row level security;

CREATE UNIQUE INDEX blocked_users_pkey ON public.blocked_users USING btree (user_id, block_user_id);

alter table "public"."blocked_users" add constraint "blocked_users_pkey" PRIMARY KEY using index "blocked_users_pkey";

alter table "public"."blocked_users" add constraint "blocked_users_block_user_id_fkey" FOREIGN KEY (block_user_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."blocked_users" validate constraint "blocked_users_block_user_id_fkey";

alter table "public"."blocked_users" add constraint "blocked_users_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."blocked_users" validate constraint "blocked_users_user_id_fkey";

grant delete on table "public"."blocked_users" to "anon";

grant insert on table "public"."blocked_users" to "anon";

grant references on table "public"."blocked_users" to "anon";

grant select on table "public"."blocked_users" to "anon";

grant trigger on table "public"."blocked_users" to "anon";

grant truncate on table "public"."blocked_users" to "anon";

grant update on table "public"."blocked_users" to "anon";

grant delete on table "public"."blocked_users" to "authenticated";

grant insert on table "public"."blocked_users" to "authenticated";

grant references on table "public"."blocked_users" to "authenticated";

grant select on table "public"."blocked_users" to "authenticated";

grant trigger on table "public"."blocked_users" to "authenticated";

grant truncate on table "public"."blocked_users" to "authenticated";

grant update on table "public"."blocked_users" to "authenticated";

grant delete on table "public"."blocked_users" to "service_role";

grant insert on table "public"."blocked_users" to "service_role";

grant references on table "public"."blocked_users" to "service_role";

grant select on table "public"."blocked_users" to "service_role";

grant trigger on table "public"."blocked_users" to "service_role";

grant truncate on table "public"."blocked_users" to "service_role";

grant update on table "public"."blocked_users" to "service_role";

create policy "Enable delete for users based on user_id"
on "public"."blocked_users"
as permissive
for delete
to public
using ((( SELECT auth.uid() AS uid) = user_id));


create policy "Enable insert for users based on user_id"
on "public"."blocked_users"
as permissive
for insert
to public
with check ((( SELECT auth.uid() AS uid) = user_id));


create policy "Enable select for users based on user_id"
on "public"."blocked_users"
as permissive
for select
to public
using ((( SELECT auth.uid() AS uid) = user_id));



