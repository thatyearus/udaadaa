insert into storage.buckets(id, name) values ('ImageMessages', 'ImageMessages');

create policy "Give users access to room folder - insert"
on "storage"."objects"
as permissive
for insert
to public
with check (((bucket_id = 'ImageMessages'::text) AND (is_room_participant((storage.foldername(name))[1]::uuid))));


create policy "Give users authenticated access to room folder - select"
on "storage"."objects"
as permissive
for select
to public
using (((bucket_id = 'ImageMessages'::text) AND (is_room_participant((storage.foldername(name))[1]::uuid))));

