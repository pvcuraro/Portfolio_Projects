#I first started by looking at some general analysis of the data

#Find out the total number of Members trips vs Casual trips
SELECT 
	COUNT(ride_id) as total_trips,
    (SELECT COUNT(ride_id)
    FROM trip_data
    WHERE member_casual = 'member'
    ) as total_member_trips,
    (SELECT COUNT(ride_id)
    FROM trip_data
    WHERE member_casual = 'casual'
    ) as total_casual_trips
FROM trip_data;

#Look at average trip time for each bike type
SELECT rideable_type, SEC_TO_TIME(AVG(TIME_TO_SEC(trip_time))) as avg_trip_time
FROM trip_data
GROUP BY rideable_type
ORDER BY rideable_type DESC;

#Count of trips per bike type
SELECT rideable_type, COUNT(ride_id) as count_trips
FROM trip_data
GROUP BY rideable_type
ORDER BY rideable_type DESC;

#find out the type of bike used most by members and casual riders
SELECT
	member_casual,
    SUM(IF(rideable_type = 'docked_bike',1,0)) as count_docked,
    SUM(IF(rideable_type = 'electric_bike',1,0)) as count_electric,
    SUM(IF(rideable_type = 'classic_bike',1,0)) as count_classic
FROM trip_data
GROUP BY member_casual;

#I then decided what I felt would be most important to answer the business task and wrote code to answer those questions

#determine the count of trips per day of the week by members and casual riders
#first need to add day of the week as a column
ALTER TABLE trip_data
ADD day_of_week text;

UPDATE trip_data
SET day_of_week = WEEKDAY(started_at)
WHERE member_casual = 'casual';

UPDATE trip_data
SET day_of_week = WEEKDAY(started_at)
WHERE member_casual = 'member';

#have to update for month of May as we had an issue with the data originally
UPDATE trip_data
SET day_of_week = WEEKDAY(started_at)
WHERE month = 5;

#used the code below to make sure the update worked and there were no empty values
SELECT started_at, day_of_week
FROM trip_data
WHERE day_of_week is NULL;

#Code to find the count of trips per day of the week
SELECT COUNT(ride_id), day_of_week, member_casual
FROM trip_data
GROUP BY member_casual, day_of_week
ORDER BY day_of_week, member_casual;

#Count of trips per month
SELECT COUNT(ride_id), month, member_casual
FROM trip_data
GROUP BY member_casual, month
ORDER BY month, member_casual;

#find the count of trips per season by members and casuals
SELECT
	COUNT(ride_id),
    member_casual,
    CASE
		WHEN month in (12, 1, 2) then 'Winter'
        WHEN month in (3, 4, 5) then 'Spring'
        WHEN month in (6, 7, 8) then 'Summer'
        ELSE 'Fall'
	END AS seasons
FROM trip_data
GROUP BY member_casual, seasons
ORDER BY seasons;

#determine the average trip time member vs casual
SELECT
	SEC_TO_TIME(AVG(TIME_TO_SEC(trip_time))) as avg_trip_time, member_casual
FROM trip_data
GROUP BY member_casual;

#determine the average trip time per month by members and casual riders
SELECT
	SEC_TO_TIME(AVG(TIME_TO_SEC(trip_time))) as avg_trip_time, member_casual, month, year
FROM trip_data
GROUP BY member_casual, month, year
ORDER BY year desc, month, member_casual;

#determine average trip time per day of the week
SELECT
	SEC_TO_TIME(AVG(TIME_TO_SEC(trip_time))) as avg_trip_time, member_casual, day_of_week
FROM trip_data
GROUP BY member_casual, day_of_week
ORDER BY day_of_week, member_casual;

#determine average trip time per season by members and casual riders
#Use case statement to group months by season
SELECT
	SEC_TO_TIME(AVG(TIME_TO_SEC(trip_time))) as avg_trip_time,
    member_casual,
    CASE
		WHEN month in (12, 1, 2) then 'Winter'
        WHEN month in (3, 4, 5) then 'Spring'
        WHEN month in (6, 7, 8) then 'Summer'
        ELSE 'Fall'
	END AS seasons
FROM trip_data
GROUP BY member_casual, seasons
ORDER BY seasons;

#save out separate datasets for each month for visualization
SELECT ride_id, rideable_type, member_casual, day_of_week, month, year, trip_time
FROM trip_data
WHERE month = 5;
