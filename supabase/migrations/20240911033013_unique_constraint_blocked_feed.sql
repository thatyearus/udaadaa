ALTER TABLE blocked_feed 
ADD CONSTRAINT user_feed_unique_blocked_feed UNIQUE (user_id, feed_id);