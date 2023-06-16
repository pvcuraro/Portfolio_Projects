#Created the table using the data import wizard and then loaded data into the table with LOAD DATA LOCAL INFILE query

LOAD DATA LOCAL INFILE 'C:/Users/pvcur/Documents/Data Analytics/Portfolio/Projects/SIS Basketball Research/nba_player_game_logs.csv'
into table sis_basketball_research.nba_player_game_logs
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

#Select all to see what the table looks like
Select * from sis_basketball_research.nba_player_game_logs;

#Find top scorer on each team based on FG_PCT
SELECT 
	p.PLAYER_NAME, p.TEAM, p.AVG_FG_PCT
FROM (
    SELECT 
		TEAM, MAX(AVG_FG_PCT) AS max_avg_fg_pct
    FROM (
        SELECT 
			TEAM, PLAYER_NAME, AVG(FG_PCT) AS AVG_FG_PCT
        FROM 
			nba_player_game_logs
        GROUP BY 
			TEAM, PLAYER_NAME
        HAVING 
			AVG(FG_PCT) < 1 -- Exclude players with an average of 1
    ) AS p_avg_fg_pct
    GROUP BY TEAM
) AS max_avg
JOIN (
    SELECT 
		TEAM, PLAYER_NAME, AVG(FG_PCT) AS AVG_FG_PCT
    FROM 
		nba_player_game_logs
    GROUP BY 
		TEAM, PLAYER_NAME
    HAVING 
		AVG(FG_PCT) < 1 -- Exclude players with an average of 1
) AS p ON p.TEAM = max_avg.TEAM AND p.AVG_FG_PCT = max_avg.max_avg_fg_pct
ORDER BY p.TEAM ASC;

/*Find average fg_pct, fg3_pct, rebounds, assists, points, steals and blocks during the
playoffs to determine if one player stood out from the rest (playoffs started on
04-16-2022*/

SELECT 
	PLAYER_NAME, 
    TEAM, 
    AVG(PTS), 
    AVG(AST), 
    AVG(REB), 
    AVG(STL),
    AVG(BLK), 
    AVG(FG_PCT), 
    AVG(FG3_PCT)
FROM
	nba_player_game_logs
WHERE
	game_date >= "2022-04-16"
GROUP BY 
	PLAYER_NAME, TEAM
ORDER BY 
	TEAM;

/*Select Players who average a double double during the regular season*/

SELECT
	PLAYER_NAME,
    AVG(PTS),
    AVG(REB),
    AVG(AST)
FROM 
	nba_player_game_logs
WHERE
	game_date <= "2022-04-16"
GROUP BY
	PLAYER_NAME
HAVING
	AVG(PTS) >= 10 AND (AVG(REB) >= 10 OR AVG(AST) >= 10);
    
/*Creating a running average of player points by game_date to determine if a player
was trending up or down during the season*/

SELECT
	PLAYER_NAME,
    game_date,
    PTS,
    AVG(PTS)
		OVER
			(PARTITION BY PLAYER_NAME
            ORDER BY game_date) as rolling_avg_pts
FROM 
	nba_player_game_logs
WHERE 
	game_date <= "2022-04-16";
    
CREATE VIEW running_player_avg_pts as
SELECT
	PLAYER_NAME,
    game_date,
    PTS,
    AVG(PTS)
		OVER
			(PARTITION BY PLAYER_NAME
            ORDER BY game_date) as rolling_avg_pts
FROM 
	nba_player_game_logs
WHERE 
	game_date <= "2022-04-16";
    
CREATE VIEW double_double_by_player as
SELECT
	PLAYER_NAME,
    AVG(PTS),
    AVG(REB),
    AVG(AST)
FROM 
	nba_player_game_logs
WHERE
	game_date <= "2022-04-16"
GROUP BY
	PLAYER_NAME
HAVING
	AVG(PTS) >= 10 AND (AVG(REB) >= 10 OR AVG(AST) >= 10);
    
CREATE VIEW avg_stats_per_player as
SELECT 
	PLAYER_NAME, 
    TEAM, 
    AVG(PTS), 
    AVG(AST), 
    AVG(REB), 
    AVG(STL),
    AVG(BLK), 
    AVG(FG_PCT), 
    AVG(FG3_PCT)
FROM
	nba_player_game_logs
WHERE
	game_date >= "2022-04-16"
GROUP BY 
	PLAYER_NAME, TEAM
ORDER BY 
	TEAM;