 --TRIP 207--

SELECT *
	FROM .[207_TRIP]


--BIKES USED BY CASUAL RIDES WHOS ID WASNT REGISTERED --
SELECT *
	FROM DBO.[207_TRIP]
	WHERE ride_id IS NULL
	AND member_casual like ('casual')
	
--BIKES USED BY MEMBERS RIDES WHOS ID WASNT REGISTERED--
SELECT *
	FROM DBO.[207_TRIP]
	WHERE ride_id IS NULL
	AND member_casual like ('MEMBER')

-- HOW MANY MEMBER_CASUAL HAVE HAVENT BEEN REGISTERED--
--SELECT COUNT(ride_id),member_casual
--FROM dbo.[207_TRIP]
--	WHERE ride_id IS NULL
--	GROUP BY member_casual


-- HOW MANY BIKES WHERE STOLEN /MISSING --
SELECT start_station_name,end_station_name
	FROM.[207_TRIP]
	WHERE start_station_name IS NULL
		AND end_station_name IS NULL


--NUMBER IF BIKES NOT RETURNED AFTER USE--
SELECT COUNT(rideable_type) AS NUM_OF_UNRETURNED_BIKES ,member_casual,rideable_type
	FROM .[207_TRIP]
	WHERE end_station_id IS NULL
GROUP BY member_casual , rideable_type
ORDER BY NUM_OF_UNRETURNED_BIKES DESC



--THE TIME USER SPENT RIDING--
WITH
	CTE_TRIP207 AS 
	(
		SELECT ride_id,rideable_type,
				member_casual,
				CONVERT(DATE,started_at) AS StartDate,
				CONVERT(DATE,ended_at) AS EndDate ,
				CONVERT(time(0),started_at)AS StartTime,
				CONVERT(time(0),ended_at)AS EndTime
	
		FROM .[207_TRIP]
	)
	
SELECT	ride_id,EndTime,StartTime,CONCAT((DATEDIFF(MINUTE,StartTime,EndTime)),' ','Mins') AS RideTime
FROM CTE_TRIP207
ORDER BY RideTime DESC



--COUNT OF RIDERS ON A PARTICULAR DAY--

WITH
	CTE_TRIP207 AS 
	(
		SELECT ride_id,rideable_type,
				member_casual,
				CONVERT(DATE,started_at) AS StartDate,
				CONVERT(DATE,ended_at) AS EndDate ,
				CONVERT(time(0),started_at)AS StartTime,
				CONVERT(time(0),ended_at)AS EndTime,
				DAY(started_at) as BikeDay
		FROM .[207_TRIP]
	)
	
SELECT COUNT(BikeDay) AS Num_Of_Riders,BikeDay,member_casual
	FROM CTE_TRIP207
		GROUP BY BikeDay,member_casual
		ORDER BY member_casual,BikeDay



--ALL TRIPS--

DROP TABLE IF EXISTS #ALLTRIPS

CREATE TABLE #ALLTRIPS (
	ID VARCHAR(255),
	BikeType VARCHAR(255),
	StartDATE DATE,
	EndDate DATE,
	StartTime TIME(0),
	EndTime TIME(0),
	StartStation VARCHAR(255),
	EndStation VARCHAR(255)
	)

INSERT INTO #ALLTRIPS

SELECT ride_id,rideable_type,CONVERT (DATE,started_at),CONVERT(DATE,ended_at),CONVERT(TIME(0),started_at)
		,CONVERT(TIME(0),ended_at),start_station_name,end_station_name
	FROM .[207_TRIP]
		UNION ALL
SELECT ride_id,rideable_type,CONVERT (DATE,started_at),CONVERT(DATE,ended_at),CONVERT(TIME(0),started_at)
		,CONVERT(TIME(0),ended_at),start_station_name,end_station_name
	FROM .[208_TRIP]
		UNION ALL
SELECT ride_id,rideable_type,CONVERT (DATE,started_at),CONVERT(DATE,ended_at),CONVERT(TIME(0),started_at)
		,CONVERT(TIME(0),ended_at),start_station_name,end_station_name
	FROM .[209_TRIP]
		UNION ALL
SELECT ride_id,rideable_type,CONVERT (DATE,started_at),CONVERT(DATE,ended_at),CONVERT(TIME(0),started_at)
		,CONVERT(TIME(0),ended_at),start_station_name,end_station_name
	FROM .[210_TRIP]


SELECT*
FROM #ALLTRIPS
ORDER BY  StartDATE


--RIDER IN TRIP WHO ARE IN ALL TRIPS WITH THE SAME START AND END STATION--

SELECT ride_id, #ALLTRIPS.StartStation, #ALLTRIPS.EndStation
FROM [207_TRIP]
	JOIN
	#ALLTRIPS
 ON .[207_TRIP].ride_id = #ALLTRIPS.ID
 WHERE .[207_TRIP].start_station_name = #ALLTRIPS.StartStation
		AND
		.[207_TRIP].end_station_name = #ALLTRIPS.EndStation


--BIKE TYPE THAT WAS USED MORE--
SELECT COUNT(BikeType) AS COUNT_NUM,BikeType
FROM #ALLTRIPS
GROUP BY BikeType
ORDER BY COUNT(BikeType) DESC


--ID WITH NO START AND END STATION --
SELECT ID
FROM #ALLTRIPS
WHERE StartStation IS NULL 
	AND
	EndStation IS NULL