create policy "Users can insert read_receipt on rooms they are in."
on "public"."read_receipts"
as permissive
for insert
to public
with check ((is_room_participant(room_id) AND (( SELECT auth.uid() AS uid) = user_id)));


create policy "Users can view read_receipts on rooms they are in."
on "public"."read_receipts"
as permissive
for select
to public
using (is_room_participant(room_id));



