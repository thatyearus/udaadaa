create policy "Users can insert messages on rooms they are in."
on "public"."messages"
as permissive
for insert
to public
with check ((is_room_participant(room_id) AND (auth.uid() = user_id)));


create policy "Users can view messages on rooms they are in."
on "public"."messages"
as permissive
for select
to public
using (is_room_participant(room_id));


create policy "Enable delete for users based on user_id"
on "public"."room_participants"
as permissive
for delete
to public
using ((( SELECT auth.uid() AS uid) = user_id));


create policy "Enable insert for users based on user_id"
on "public"."room_participants"
as permissive
for insert
to public
with check ((( SELECT auth.uid() AS uid) = user_id));


create policy "Participants of the room can view other participants."
on "public"."room_participants"
as permissive
for select
to public
using (is_room_participant(room_id));


create policy "Users can view rooms that they have joined"
on "public"."rooms"
as permissive
for select
to public
using (is_room_participant(id));



