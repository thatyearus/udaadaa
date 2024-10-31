create table "public"."weight" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone not null default now(),
    "weight" double precision not null,
    "date" date not null,
    "user_id" uuid not null default gen_random_uuid()
);


alter table "public"."weight" enable row level security;

CREATE UNIQUE INDEX weight_pkey ON public.weight USING btree (id);

alter table "public"."weight" add constraint "weight_pkey" PRIMARY KEY using index "weight_pkey";

alter table "public"."weight" add constraint "weight_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."weight" validate constraint "weight_user_id_fkey";

grant delete on table "public"."weight" to "anon";

grant insert on table "public"."weight" to "anon";

grant references on table "public"."weight" to "anon";

grant select on table "public"."weight" to "anon";

grant trigger on table "public"."weight" to "anon";

grant truncate on table "public"."weight" to "anon";

grant update on table "public"."weight" to "anon";

grant delete on table "public"."weight" to "authenticated";

grant insert on table "public"."weight" to "authenticated";

grant references on table "public"."weight" to "authenticated";

grant select on table "public"."weight" to "authenticated";

grant trigger on table "public"."weight" to "authenticated";

grant truncate on table "public"."weight" to "authenticated";

grant update on table "public"."weight" to "authenticated";

grant delete on table "public"."weight" to "service_role";

grant insert on table "public"."weight" to "service_role";

grant references on table "public"."weight" to "service_role";

grant select on table "public"."weight" to "service_role";

grant trigger on table "public"."weight" to "service_role";

grant truncate on table "public"."weight" to "service_role";

grant update on table "public"."weight" to "service_role";

create policy "Enable delete for users based on user_id"
on "public"."weight"
as permissive
for delete
to public
using ((( SELECT auth.uid() AS uid) = user_id));


create policy "Enable insert for users based on user_id"
on "public"."weight"
as permissive
for insert
to public
with check ((( SELECT auth.uid() AS uid) = user_id));


create policy "Enable read access for all authenticated users"
on "public"."weight"
as permissive
for select
to authenticated
using (true);


create policy "Enable update for users based on user_id"
on "public"."weight"
as permissive
for update
to public
using ((( SELECT auth.uid() AS uid) = user_id));



