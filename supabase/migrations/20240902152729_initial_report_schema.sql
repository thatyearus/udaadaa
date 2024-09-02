create table "public"."report" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "date" date not null,
    "created_at" timestamp with time zone not null default now(),
    "breakfast" bigint,
    "lunch" bigint,
    "dinner" bigint,
    "snack" bigint,
    "exercise" bigint,
    "weight" double precision
);


alter table "public"."report" enable row level security;

CREATE UNIQUE INDEX report_pkey ON public.report USING btree (id);

alter table "public"."report" add constraint "report_pkey" PRIMARY KEY using index "report_pkey";

alter table "public"."report" add constraint "report_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE not valid;

alter table "public"."report" validate constraint "report_user_id_fkey";

grant delete on table "public"."report" to "anon";

grant insert on table "public"."report" to "anon";

grant references on table "public"."report" to "anon";

grant select on table "public"."report" to "anon";

grant trigger on table "public"."report" to "anon";

grant truncate on table "public"."report" to "anon";

grant update on table "public"."report" to "anon";

grant delete on table "public"."report" to "authenticated";

grant insert on table "public"."report" to "authenticated";

grant references on table "public"."report" to "authenticated";

grant select on table "public"."report" to "authenticated";

grant trigger on table "public"."report" to "authenticated";

grant truncate on table "public"."report" to "authenticated";

grant update on table "public"."report" to "authenticated";

grant delete on table "public"."report" to "service_role";

grant insert on table "public"."report" to "service_role";

grant references on table "public"."report" to "service_role";

grant select on table "public"."report" to "service_role";

grant trigger on table "public"."report" to "service_role";

grant truncate on table "public"."report" to "service_role";

grant update on table "public"."report" to "service_role";

create policy "Enable delete for users based on user_id"
on "public"."report"
as permissive
for delete
to public
using ((( SELECT auth.uid() AS uid) = user_id));


create policy "Enable insert for users based on user_id"
on "public"."report"
as permissive
for insert
to public
with check ((( SELECT auth.uid() AS uid) = user_id));


create policy "Enable select for users based on user_id"
on "public"."report"
as permissive
for select
to public
using ((( SELECT auth.uid() AS uid) = user_id));


create policy "Enable update for users based on user_id"
on "public"."report"
as permissive
for update
to public
using ((( SELECT auth.uid() AS uid) = user_id));



