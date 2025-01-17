alter table "public"."messages" drop column "image_url";

alter table "public"."messages" add column "image_path" text;


