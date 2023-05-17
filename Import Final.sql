CREATE TABLE trip_data (
ride_id text,
rideable_type text,
started_at datetime,
ended_at datetime,
month int,
year int,
days varchar(20),
trip_time varchar(30),
start_station_name text,
start_station_id text,
end_station_name text,
end_station_id text,
start_lat double(10,6),
start_lng double(10,6),
end_lat double(10,6),
end_lng double(10,6),
member_casual text);

Select * from trip_data;

LOAD DATA LOCAL INFILE 'C:/Users/pvcur/Documents/Data Analytics/Portfolio/Case Studies/Trip Data/Edited Files/202205-divvy-tripdata.csv'
into table trip_data
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;

#I saw some issues where certain data was not populating correctly from the original CSV's
#Here I used DELETE functions to help remove the data and then I re-imported it with the LOAD function.

DELETE FROM trip_data WHERE member_casual = 'casual';

SELECT * from trip_data
WHERE month = 5;

DELETE
FROM may_trip_data
WHERE month = 5