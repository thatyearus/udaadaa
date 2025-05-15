create policy "Users can update messages on rooms they are in"
on "public"."messages"
for update
to public
using (
  is_room_participant(room_id)
);