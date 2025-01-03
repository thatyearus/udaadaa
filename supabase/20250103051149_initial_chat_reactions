alter table "public"."reactions" drop constraint "reactions_message_id_fkey";

create table "public"."chat_reactions" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone not null default now(),
    "user_id" uuid not null default gen_random_uuid(),
    "message_id" uuid not null default gen_random_uuid(),
    "content" text not null,
    "room_id" uuid not null
);

alter table "public"."chat_reactions" enable row level security;

alter table "public"."reactions" drop column "message_id";

CREATE UNIQUE INDEX chat_reactions_pkey ON public.chat_reactions USING btree (id);

alter table "public"."chat_reactions" add constraint "chat_reactions_pkey" PRIMARY KEY using index "chat_reactions_pkey";

alter table "public"."chat_reactions" add constraint "chat_reactions_message_id_fkey" FOREIGN KEY (message_id) REFERENCES messages(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."chat_reactions" validate constraint "chat_reactions_message_id_fkey";

alter table "public"."chat_reactions" add constraint "chat_reactions_room_id_fkey" FOREIGN KEY (room_id) REFERENCES rooms(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."chat_reactions" validate constraint "chat_reactions_room_id_fkey";

alter table "public"."chat_reactions" add constraint "chat_reactions_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."chat_reactions" validate constraint "chat_reactions_user_id_fkey";

grant delete on table "public"."chat_reactions" to "anon";

grant insert on table "public"."chat_reactions" to "anon";

grant references on table "public"."chat_reactions" to "anon";

grant select on table "public"."chat_reactions" to "anon";

grant trigger on table "public"."chat_reactions" to "anon";

grant truncate on table "public"."chat_reactions" to "anon";

grant update on table "public"."chat_reactions" to "anon";

grant delete on table "public"."chat_reactions" to "authenticated";

grant insert on table "public"."chat_reactions" to "authenticated";

grant references on table "public"."chat_reactions" to "authenticated";

grant select on table "public"."chat_reactions" to "authenticated";

grant trigger on table "public"."chat_reactions" to "authenticated";

grant truncate on table "public"."chat_reactions" to "authenticated";

grant update on table "public"."chat_reactions" to "authenticated";

grant delete on table "public"."chat_reactions" to "service_role";

grant insert on table "public"."chat_reactions" to "service_role";

grant references on table "public"."chat_reactions" to "service_role";

grant select on table "public"."chat_reactions" to "service_role";

grant trigger on table "public"."chat_reactions" to "service_role";

grant truncate on table "public"."chat_reactions" to "service_role";

grant update on table "public"."chat_reactions" to "service_role";

create policy "Enable delete for users based on user_id"
on "public"."chat_reactions"
as permissive
for delete
to public
using ((( SELECT auth.uid() AS uid) = user_id));


create policy "Users can insert reactions on rooms they are in."
on "public"."chat_reactions"
as permissive
for insert
to public
with check ((is_room_participant(room_id) AND (( SELECT auth.uid() AS uid) = user_id)));


create policy "Users can view reactions on rooms they are in."
on "public"."chat_reactions"
as permissive
for select
to public
using (is_room_participant(room_id));



