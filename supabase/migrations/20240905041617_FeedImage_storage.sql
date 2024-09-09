insert into storage.buckets(id, name) values ('FeedImages', 'FeedImages');

create policy "Give users access to own folder - insert"
on "storage"."objects"
as permissive
for insert
to public
with check (((bucket_id = 'FeedImages'::text) AND (( SELECT (auth.uid())::text AS uid) = (storage.foldername(name))[1])));


create policy "Give users access to own folder - update"
on "storage"."objects"
as permissive
for update
to public
using (((bucket_id = 'FeedImages'::text) AND (( SELECT (auth.uid())::text AS uid) = (storage.foldername(name))[1])));


create policy "Give users access to own folder - delete"
on "storage"."objects"
as permissive
for delete
to public
using (((bucket_id = 'FeedImages'::text) AND (( SELECT (auth.uid())::text AS uid) = (storage.foldername(name))[1])));


create policy "Give users authenticated access to folder - select"
on "storage"."objects"
as permissive
for select
to public
using (((bucket_id = 'FeedImages'::text) AND ((storage.foldername(name))[1] = 'private'::text) AND (auth.role() = 'authenticated'::text)));



