drop policy "Give users authenticated access to folder - select" on "storage"."objects";

create policy "Give users authenticated access to folder - select"
on "storage"."objects"
as permissive
for select
to public
using (((bucket_id = 'FeedImages'::text) AND (auth.role() = 'authenticated'::text)));



