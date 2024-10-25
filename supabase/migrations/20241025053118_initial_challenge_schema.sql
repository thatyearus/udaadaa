create table "public"."challenge" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone not null default now(),
    "start_day" date not null,
    "end_day" date not null,
    "user_id" uuid not null default gen_random_uuid()
);


alter table "public"."challenge" enable row level security;

CREATE UNIQUE INDEX challenge_pkey ON public.challenge USING btree (id);

alter table "public"."challenge" add constraint "challenge_pkey" PRIMARY KEY using index "challenge_pkey";

alter table "public"."challenge" add constraint "challenge_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."challenge" validate constraint "challenge_user_id_fkey";

grant delete on table "public"."challenge" to "anon";

grant insert on table "public"."challenge" to "anon";

grant references on table "public"."challenge" to "anon";

grant select on table "public"."challenge" to "anon";

grant trigger on table "public"."challenge" to "anon";

grant truncate on table "public"."challenge" to "anon";

grant update on table "public"."challenge" to "anon";

grant delete on table "public"."challenge" to "authenticated";

grant insert on table "public"."challenge" to "authenticated";

grant references on table "public"."challenge" to "authenticated";

grant select on table "public"."challenge" to "authenticated";

grant trigger on table "public"."challenge" to "authenticated";

grant truncate on table "public"."challenge" to "authenticated";

grant update on table "public"."challenge" to "authenticated";

grant delete on table "public"."challenge" to "service_role";

grant insert on table "public"."challenge" to "service_role";

grant references on table "public"."challenge" to "service_role";

grant select on table "public"."challenge" to "service_role";

grant trigger on table "public"."challenge" to "service_role";

grant truncate on table "public"."challenge" to "service_role";

grant update on table "public"."challenge" to "service_role";

create policy "Enable delete for users based on user_id"
on "public"."challenge"
as permissive
for delete
to public
using ((( SELECT auth.uid() AS uid) = user_id));


create policy "Enable insert for users based on user_id"
on "public"."challenge"
as permissive
for insert
to public
with check ((( SELECT auth.uid() AS uid) = user_id));


create policy "Enable read access for all authenticated users"
on "public"."challenge"
as permissive
for select
to authenticated
using (true);


create policy "Enable update for users based on user_id"
on "public"."challenge"
as permissive
for update
to public
using ((( SELECT auth.uid() AS uid) = user_id));



