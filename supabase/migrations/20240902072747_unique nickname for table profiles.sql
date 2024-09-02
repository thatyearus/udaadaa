CREATE UNIQUE INDEX profiles_nickname_key ON public.profiles USING btree (nickname);

alter table "public"."profiles" add constraint "profiles_nickname_key" UNIQUE using index "profiles_nickname_key";


