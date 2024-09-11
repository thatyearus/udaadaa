ALTER TABLE reactions 
ADD CONSTRAINT user_feed_unique_reactions UNIQUE (user_id, feed_id);