create table "public"."blocked_messages" (
    "created_at" timestamp with time zone not null default now(),
    "user_id" uuid not null default gen_random_uuid(),
    "message_id" uuid not null default gen_random_uuid(),
    "room_id" uuid not null default gen_random_uuid()
);


alter table "public"."blocked_messages" enable row level security;

CREATE UNIQUE INDEX blocked_messages_pkey ON public.blocked_messages USING btree (user_id, message_id);

alter table "public"."blocked_messages" add constraint "blocked_messages_pkey" PRIMARY KEY using index "blocked_messages_pkey";

alter table "public"."blocked_messages" add constraint "blocked_messages_message_id_fkey" FOREIGN KEY (message_id) REFERENCES messages(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."blocked_messages" validate constraint "blocked_messages_message_id_fkey";

alter table "public"."blocked_messages" add constraint "blocked_messages_room_id_fkey" FOREIGN KEY (room_id) REFERENCES rooms(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."blocked_messages" validate constraint "blocked_messages_room_id_fkey";

alter table "public"."blocked_messages" add constraint "blocked_messages_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."blocked_messages" validate constraint "blocked_messages_user_id_fkey";

grant delete on table "public"."blocked_messages" to "anon";

grant insert on table "public"."blocked_messages" to "anon";

grant references on table "public"."blocked_messages" to "anon";

grant select on table "public"."blocked_messages" to "anon";

grant trigger on table "public"."blocked_messages" to "anon";

grant truncate on table "public"."blocked_messages" to "anon";

grant update on table "public"."blocked_messages" to "anon";

grant delete on table "public"."blocked_messages" to "authenticated";

grant insert on table "public"."blocked_messages" to "authenticated";

grant references on table "public"."blocked_messages" to "authenticated";

grant select on table "public"."blocked_messages" to "authenticated";

grant trigger on table "public"."blocked_messages" to "authenticated";

grant truncate on table "public"."blocked_messages" to "authenticated";

grant update on table "public"."blocked_messages" to "authenticated";

grant delete on table "public"."blocked_messages" to "service_role";

grant insert on table "public"."blocked_messages" to "service_role";

grant references on table "public"."blocked_messages" to "service_role";

grant select on table "public"."blocked_messages" to "service_role";

grant trigger on table "public"."blocked_messages" to "service_role";

grant truncate on table "public"."blocked_messages" to "service_role";

grant update on table "public"."blocked_messages" to "service_role";

create policy "Enable delete for users based on user_id"
on "public"."blocked_messages"
as permissive
for delete
to public
using ((( SELECT auth.uid() AS uid) = user_id));


create policy "Enable insert for users based on user_id"
on "public"."blocked_messages"
as permissive
for insert
to public
with check ((is_room_participant(room_id) AND (( SELECT auth.uid() AS uid) = user_id)));


create policy "Enable select for users based on user_id"
on "public"."blocked_messages"
as permissive
for select
to public
using ((( SELECT auth.uid() AS uid) = user_id));



