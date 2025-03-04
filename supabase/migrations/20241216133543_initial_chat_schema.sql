create type "public"."MessageType" as enum ('infoMessage', 'textMessage', 'imageMessage', 'missionMessage');

create table "public"."messages" (
    "created_at" timestamp with time zone not null default now(),
    "content" text,
    "type" "MessageType" not null,
    "image_url" text,
    "user_id" uuid not null default gen_random_uuid(),
    "id" uuid not null default gen_random_uuid()
);


alter table "public"."messages" enable row level security;

create table "public"."read_receipts" (
    "created_at" timestamp with time zone not null default now(),
    "user_id" uuid not null default gen_random_uuid(),
    "message_id" uuid not null default gen_random_uuid(),
    "room_id" uuid not null default gen_random_uuid()
);


alter table "public"."read_receipts" enable row level security;

create table "public"."room_participants" (
    "created_at" timestamp with time zone not null default now(),
    "user_id" uuid not null default gen_random_uuid(),
    "room_id" uuid not null default gen_random_uuid()
);


alter table "public"."room_participants" enable row level security;

create table "public"."rooms" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone not null default now(),
    "room_name" text not null
);


alter table "public"."rooms" enable row level security;

alter table "public"."reactions" add column "message_id" uuid;

CREATE UNIQUE INDEX messages_pkey ON public.messages USING btree (id);

CREATE UNIQUE INDEX read_receipts_pkey ON public.read_receipts USING btree (user_id, message_id);

CREATE UNIQUE INDEX room_participants_pkey ON public.room_participants USING btree (user_id, room_id);

CREATE UNIQUE INDEX rooms_pkey ON public.rooms USING btree (id);

alter table "public"."messages" add constraint "messages_pkey" PRIMARY KEY using index "messages_pkey";

alter table "public"."read_receipts" add constraint "read_receipts_pkey" PRIMARY KEY using index "read_receipts_pkey";

alter table "public"."room_participants" add constraint "room_participants_pkey" PRIMARY KEY using index "room_participants_pkey";

alter table "public"."rooms" add constraint "rooms_pkey" PRIMARY KEY using index "rooms_pkey";

alter table "public"."messages" add constraint "messages_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."messages" validate constraint "messages_user_id_fkey";

alter table "public"."reactions" add constraint "reactions_message_id_fkey" FOREIGN KEY (message_id) REFERENCES messages(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."reactions" validate constraint "reactions_message_id_fkey";

alter table "public"."read_receipts" add constraint "read_receipts_message_id_fkey" FOREIGN KEY (message_id) REFERENCES messages(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."read_receipts" validate constraint "read_receipts_message_id_fkey";

alter table "public"."read_receipts" add constraint "read_receipts_room_id_fkey" FOREIGN KEY (room_id) REFERENCES rooms(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."read_receipts" validate constraint "read_receipts_room_id_fkey";

alter table "public"."read_receipts" add constraint "read_receipts_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."read_receipts" validate constraint "read_receipts_user_id_fkey";

alter table "public"."room_participants" add constraint "room_participants_room_id_fkey" FOREIGN KEY (room_id) REFERENCES rooms(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."room_participants" validate constraint "room_participants_room_id_fkey";

alter table "public"."room_participants" add constraint "room_participants_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."room_participants" validate constraint "room_participants_user_id_fkey";

grant delete on table "public"."messages" to "anon";

grant insert on table "public"."messages" to "anon";

grant references on table "public"."messages" to "anon";

grant select on table "public"."messages" to "anon";

grant trigger on table "public"."messages" to "anon";

grant truncate on table "public"."messages" to "anon";

grant update on table "public"."messages" to "anon";

grant delete on table "public"."messages" to "authenticated";

grant insert on table "public"."messages" to "authenticated";

grant references on table "public"."messages" to "authenticated";

grant select on table "public"."messages" to "authenticated";

grant trigger on table "public"."messages" to "authenticated";

grant truncate on table "public"."messages" to "authenticated";

grant update on table "public"."messages" to "authenticated";

grant delete on table "public"."messages" to "service_role";

grant insert on table "public"."messages" to "service_role";

grant references on table "public"."messages" to "service_role";

grant select on table "public"."messages" to "service_role";

grant trigger on table "public"."messages" to "service_role";

grant truncate on table "public"."messages" to "service_role";

grant update on table "public"."messages" to "service_role";

grant delete on table "public"."read_receipts" to "anon";

grant insert on table "public"."read_receipts" to "anon";

grant references on table "public"."read_receipts" to "anon";

grant select on table "public"."read_receipts" to "anon";

grant trigger on table "public"."read_receipts" to "anon";

grant truncate on table "public"."read_receipts" to "anon";

grant update on table "public"."read_receipts" to "anon";

grant delete on table "public"."read_receipts" to "authenticated";

grant insert on table "public"."read_receipts" to "authenticated";

grant references on table "public"."read_receipts" to "authenticated";

grant select on table "public"."read_receipts" to "authenticated";

grant trigger on table "public"."read_receipts" to "authenticated";

grant truncate on table "public"."read_receipts" to "authenticated";

grant update on table "public"."read_receipts" to "authenticated";

grant delete on table "public"."read_receipts" to "service_role";

grant insert on table "public"."read_receipts" to "service_role";

grant references on table "public"."read_receipts" to "service_role";

grant select on table "public"."read_receipts" to "service_role";

grant trigger on table "public"."read_receipts" to "service_role";

grant truncate on table "public"."read_receipts" to "service_role";

grant update on table "public"."read_receipts" to "service_role";

grant delete on table "public"."room_participants" to "anon";

grant insert on table "public"."room_participants" to "anon";

grant references on table "public"."room_participants" to "anon";

grant select on table "public"."room_participants" to "anon";

grant trigger on table "public"."room_participants" to "anon";

grant truncate on table "public"."room_participants" to "anon";

grant update on table "public"."room_participants" to "anon";

grant delete on table "public"."room_participants" to "authenticated";

grant insert on table "public"."room_participants" to "authenticated";

grant references on table "public"."room_participants" to "authenticated";

grant select on table "public"."room_participants" to "authenticated";

grant trigger on table "public"."room_participants" to "authenticated";

grant truncate on table "public"."room_participants" to "authenticated";

grant update on table "public"."room_participants" to "authenticated";

grant delete on table "public"."room_participants" to "service_role";

grant insert on table "public"."room_participants" to "service_role";

grant references on table "public"."room_participants" to "service_role";

grant select on table "public"."room_participants" to "service_role";

grant trigger on table "public"."room_participants" to "service_role";

grant truncate on table "public"."room_participants" to "service_role";

grant update on table "public"."room_participants" to "service_role";

grant delete on table "public"."rooms" to "anon";

grant insert on table "public"."rooms" to "anon";

grant references on table "public"."rooms" to "anon";

grant select on table "public"."rooms" to "anon";

grant trigger on table "public"."rooms" to "anon";

grant truncate on table "public"."rooms" to "anon";

grant update on table "public"."rooms" to "anon";

grant delete on table "public"."rooms" to "authenticated";

grant insert on table "public"."rooms" to "authenticated";

grant references on table "public"."rooms" to "authenticated";

grant select on table "public"."rooms" to "authenticated";

grant trigger on table "public"."rooms" to "authenticated";

grant truncate on table "public"."rooms" to "authenticated";

grant update on table "public"."rooms" to "authenticated";

grant delete on table "public"."rooms" to "service_role";

grant insert on table "public"."rooms" to "service_role";

grant references on table "public"."rooms" to "service_role";

grant select on table "public"."rooms" to "service_role";

grant trigger on table "public"."rooms" to "service_role";

grant truncate on table "public"."rooms" to "service_role";

grant update on table "public"."rooms" to "service_role";


