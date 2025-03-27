ALTER TABLE rooms
ADD CONSTRAINT unique_room_name UNIQUE (room_name);
