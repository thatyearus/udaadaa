ALTER TABLE report
ADD CONSTRAINT user_date_unique UNIQUE (user_id, date);