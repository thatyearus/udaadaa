create policy "Enable update for users based on user_id"
on "public"."room_participants"
as permissive
for update
to public
using ((( SELECT auth.uid() AS uid) = user_id));



