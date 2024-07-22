USE IPL;

# ===============================================================================================================================================================
# 1. Show the percentage of wins of each bidder in the order of highest to lowest percentage.

DESC ipl_match_schedule; 
SELECT * FROM ipl_bidding_details;
SELECT * FROM ipl_bidder_details;
SELECT * FROM ipl_bidder_points;

With bids_won AS(
	SELECT 
		bidder_id, COUNT(bid_status) AS No_Of_Bids_Won
	FROM
		ipl_bidding_details
	WHERE
		bid_status = 'WON'
	GROUP BY bidder_id
) 
SELECT 
    bids_won.bidder_id,
    bids_won.No_of_Bids_won,
    bp.No_of_bids,
    (bids_won.No_of_bids_won / bp.No_of_bids) * 100 AS Percent_Wins
FROM
    bids_won
        JOIN
    ipl_bidder_details bd ON bids_won.bidder_id = bd.bidder_id
        JOIN
    ipl_bidder_points bp ON bd.bidder_id = bp.bidder_id
ORDER BY percent_wins DESC;

# Inference - The bidder_id 103 has the highest percentage of wins considering the no of bids he applied and the no of bids he won.

# ===============================================================================================================================================================
# 2. Display the number of matches conducted at each stadium with the stadium name and city.

SHOW TABLES ; 
SELECT * FROM ipl_match_schedule;
SELECT * FROM ipl_stadium;

SELECT 
    s.stadium_id, s.stadium_name, s.city, COUNT(ms.match_id)
FROM
    ipl_match_schedule ms
        INNER JOIN
    ipl_stadium s ON s.stadium_id = ms.stadium_id
WHERE ms.status = 'Completed'
# WHERE ms.status = 'Completed'
GROUP BY s.stadium_id
ORDER BY COUNT(match_id) DESC;

#Inference - If we cosider only schedule matches 'Is Bindra Stadium' in Mohali will have count of 16 matches whereas there are two matches which were scheduled and cancelled 
# so if we consider only scheduled and completed matches then 'Is Bindra Stadium' will have count of 14 matches.

# ===============================================================================================================================================================
# 3. In a given stadium, what is the percentage of wins by a team that has won the toss?
        
SHOW TABLES ; 
SELECT * FROM ipl_match;
SELECT * FROM ipl_match_schedule;
SELECT * FROM ipl_stadium;

SELECT 
    ist.stadium_name,
    (SUM((CASE
        WHEN toss_winner = match_winner THEN 1
        ELSE 0
    END)) / COUNT(*)) * 100 AS PERCENTAGE_OF_WINS
FROM
    ipl_stadium ist
        JOIN
    ipl_match_schedule ms ON ist.stadium_id = ms.stadium_id
        JOIN
    ipl_match im ON ms.match_id = im.match_id
GROUP BY ist.stadium_name
ORDER BY Percentage_of_wins DESC;        


#Inference - 'Sawai Mansingh Stadium' is where a toss winning team has more chance of winning the match.

# ===============================================================================================================================================================
# 4. Show the total bids along with the bid team and team name.

SELECT 
    SUM(no_of_bids) Total_no_Bids, bid_team, team_name
FROM
    ipl_bidding_details bd
        INNER JOIN
    ipl_bidder_points bp ON bd.bidder_id = bp.bidder_id
        INNER JOIN
    ipl_team t ON bd.Bid_team = t.team_id
GROUP BY bid_team
ORDER BY bid_team;

#Inference - 'Sunrisers Hyderabad' is the bid team has highest total no of bids

# ===============================================================================================================================================================
# 5. Show the team ID who won the match as per the win details.
		
select * from ipl_match;
select * from ipl_team;
WITH temp_table AS (
	SELECT Win_Details
	FROM ipl_match
    )
SELECT 
    Team_id, Team_name
FROM
    ipl_team,
    temp_table
WHERE
    Win_Details LIKE CONCAT('%', remarks, '%');
    
#Inference - The output signifies the team name and team id that won the match.

# ===============================================================================================================================================================
# 6. Display the total matches played, total matches won and total matches lost by the team along with its team name.
		
SELECT 
    t.Team_ID,
    t.Team_Name,
    SUM(matches_won) as Total_Matches_Won,
    SUM(matches_lost) as Total_Matches_Lost,
    SUM(matches_played) as Total_Matches_Played
FROM
    ipl_team_standings ts
        JOIN
    ipl_team t ON ts.Team_ID = t.Team_ID
GROUP BY Team_id , Team_Name;

# Inferences - 'Chennai Super Kings' team won the maximum matches.

# ===============================================================================================================================================================
# 7. Display the bowlers for the Mumbai Indians team.

select * from ipl_player;
select * from ipl_team_players;
select * from ipl_team;

SELECT 
    Player_id, Player_Name
FROM
    ipl_player
WHERE
    Player_id IN (SELECT 
            player_id
        FROM
            ipl_team_players
        WHERE
            team_id IN (SELECT 
                    team_id
                FROM
                    ipl_team
                WHERE
                    team_name = 'Mumbai Indians')
                AND Player_Role = 'Bowler');
                
#Inferences - There are 9 bowlers in mumbai indians the names are mentioned in the output.

# ===============================================================================================================================================================        
# 8. How many all-rounders are there in each team, Display the teams with more than 4 all-rounders in descending order.
		
SELECT 
    p.team_id, team_name, COUNT(*) No_of_All_Rounders
FROM
    ipl_team_players p
        JOIN
    ipl_team t 
    ON t.team_id = p.team_id
WHERE
    player_role = 'All-Rounder'
GROUP BY team_id
HAVING COUNT(*) > 4
ORDER BY No_of_All_Rounders DESC;

#Inferences - 'Delhi Daredevils' and 'Kings XI Punjab' both have equally maximum number of all rounders.

# ===============================================================================================================================================================        
# 9. Write a query to get the total bidders' points for each bidding status of those bidders who bid on CSK when they won the match in M. Chinnaswamy Stadium 
#	 bidding year-wise. Note the total bidders’ points in descending order and the year is the bidding year. 
# 	 Display columns: bidding status, bid date as year, total bidder’s points
select * from ipl_bidding_details;
select * from ipl_bidder_points;
select * from ipl_match_schedule;
select * from ipl_stadium;
select * from ipl_match;
SELECT 
    Bid_status,
    YEAR(Bid_date) Bidding_Year,
    SUM(total_points) Total_Bidder_Points
FROM
    ipl_bidding_details bd
        JOIN
    ipl_bidder_points bp 
	ON bd.bidder_id = bp.bidder_id
        JOIN
    ipl_match_schedule ms 
    ON bd.schedule_id = ms.schedule_id
        JOIN
    ipl_match m 
    ON m.Match_id = ms.match_id
WHERE
    ms.stadium_id = (SELECT 
            stadium_id
        FROM
            ipl_stadium AS s
        WHERE
             s.Stadium_name = 'M. Chinnaswamy Stadium')
	    and m.win_details LIKE '%CSK%'
GROUP BY Bid_status , Bidding_Year
ORDER BY Total_Bidder_Points DESC;

#Inference - In the year 2017 Total_Bidder_Points of the winning bid_status is 17. 

# ===============================================================================================================================================================
# 10. Extract the Bowlers and All-Rounders that are in the 5 highest number of wickets.
#    Note 
#    1. Use the performance_dtls column from ipl_player to get the total number of wickets
#    2. Do not use the limit method because it might not give appropriate results when players have the same number of wickets
#    3.	Do not use joins in any cases.
#    4.	Display the following columns teamn_name, player_name, and player_role.

		SELECT team_name, player_name, player_role
        FROM ipl_player ip,
			( SELECT t.team_id, t.team_name, player_id,player_role 
            FROM ipl_team t, ipl_team_players tp
            WHERE t.team_id = tp.team_id IN ( SELECT Player_id FROM ipl_team_players
											  WHERE player_id IN (SELECT player_id FROM (SELECT player_id, dense_rank() over(order by substring(performance_dtls,instr(performance_dtls,"Wkt") +4,
                                              (instr(performance_dtls,"Dot") -5)-instr(Performance_dtls,"Wkt"))desc) AS ranking
				FROM ipl_player 
				WHERE player_id IN (SELECT Player_id FROm ipl_team_players WHERE player_role = "Bowler" Or player_role = "All-Rounder"))a
			WHERE ranking <=5))) temp
            WHERE ip.player_id = temp.player_id;


# ===============================================================================================================================================================
#  11. show the percentage of toss wins of each bidder and display the results in descending order based on the percentage

select * from ipl_match;
select * from ipl_match_schedule;
select * from ipl_bidding_details;
select * from ipl_bidder_points;
select * from ipl_bidder_details;

	SELECT 
    bd.BIDDER_ID,
    bd.BIDDER_NAME,
    (SUM(CASE
        WHEN
            (m.TEAM_ID1 = bg.BID_TEAM
                AND m.TOSS_WINNER = 1)
                OR (m.TEAM_ID2 = bg.BID_TEAM
                AND m.TOSS_WINNER = 2)
        THEN
            1
        ELSE 0
    END) / COUNT(*)) * 100 AS Toss_Win_Percentage
FROM
    ipl_match m
        INNER JOIN
    ipl_match_schedule schd ON m.MATCH_ID = schd.MATCH_ID
        INNER JOIN
    ipl_bidding_details bg ON schd.SCHEDULE_ID = bg.SCHEDULE_ID
        INNER JOIN
    ipl_bidder_details bd ON bg.BIDDER_ID = bd.BIDDER_ID
        INNER JOIN
    ipl_bidder_points pts ON bd.BIDDER_ID = pts.BIDDER_ID
GROUP BY bd.BIDDER_ID , bd.BIDDER_NAME
ORDER BY Toss_Win_Percentage DESC;
    
# Inferences - 'Mishri Nayar' is the bidder who won the maximum no of bid with winning percentage of 88.88%.

# ===============================================================================================================================================================
# 12. find the IPL season which has a duration and max duration.
# Output columns should be like the below: Tournment_ID, Tourment_name, Duration column, Duration

select * from ipl_tournament;
WITH ipl AS (																		
    SELECT Tournmt_ID, Tournmt_name, DATEDIFF(TO_DATE, FROM_DATE) AS Duration
    FROM ipl_tournament),max_durations AS (								
    SELECT MAX(Duration) AS Max_Duration
    FROM
        ipl), min_durations AS (
    SELECT MIN(Duration) AS Min_Duration
    FROM ipl
)
SELECT Tournmt_ID, Tournmt_name, Duration,
    CASE
        WHEN Duration = (SELECT Max_Duration FROM max_durations) THEN 'Max_duration'
        WHEN Duration = (SELECT Min_Duration FROM min_durations) THEN 'Min_duration'
    END AS Duration_Column
FROM ipl;

# Inferences- The Minimum duration IPL of 36 days was in 2009 and the max duration of IPL of 53 days was in 2012 and 2013.

# ===============================================================================================================================================================
#   13. Write a query to display to calculate the total points month-wise for the 2017 bid year. sort the results based on total points in descending order and month-wise in ascending order.
#   Note: Display the following columns: 1.	Bidder ID, 2. Bidder Name, 3. Bid date as Year, 4. Bid date as Month, 5. Total points Only use joins for the above query queries.

	SELECT 
    bd.bidder_id,
    bd.bidder_name,
    YEAR(bg.bid_date) Bid_year,
    MONTH(bg.bid_date) bid_month,
    pts.Total_points
FROM
    ipl_bidder_details bd
        INNER JOIN
    ipl_bidder_points pts ON bd.bidder_id = pts.bidder_id
        INNER JOIN
    ipl_bidding_details bg ON pts.bidder_id = bg.bidder_id
WHERE
    YEAR(bg.bid_date) = 2017
ORDER BY total_points DESC , bid_month ASC;

#Inferences - 'Aryabhatta Parachure' has max. total points with bid month =4 and bid year = 2017.

# ===============================================================================================================================================================
#  14. Write a query for the above question using sub-queries by having the same constraints as the above question.

		SELECT 
    bd.bidder_id,
    bd.bidder_name,
    YEAR(bg.bid_date) bid_year,
    MONTHNAME(bg.bid_date) AS bid_month,
    pts.total_points
FROM
    ipl_bidding_details bg
        INNER JOIN
    ipl_bidder_details bd ON bg.bidder_id = bd.bidder_id
        INNER JOIN
    ipl_bidder_points pts ON bg.bidder_id = pts.bidder_id
WHERE
    YEAR(bg.bid_date) = 2017
GROUP BY bd.bidder_id , bg.bid_date , bd.bidder_name , pts.total_points
ORDER BY Total_points DESC;

#Inferences - 'Aryabhatta Parachure' has max. total points with bid month =4 and bid year = 2017.

# ===============================================================================================================================================================
# 15. Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
# Output columns should be: like - Bidder Id, Ranks (optional), Total points, Highest_3_Bidders --> columns contains name of bidder, Lowest_3_Bidders  --> columns contains name of bidder;

		with highest AS(
        SELECT pts.bidder_id,pts.total_points,bd.bidder_name,dense_rank() over (order by pts.total_points desc) as rank_h
        FROM ipl_bidder_points pts
        INNER JOIN ipl_bidder_details bd
        ON pts.bidder_id = bd.bidder_id
        )
        select * from highest WHERE rank_h <4;
        
        
        with lowest AS(
        SELECT pts.bidder_id,pts.total_points,bd.bidder_name,dense_rank() over (order by pts.total_points ) as rank_l
        FROM ipl_bidder_points pts
        INNER JOIN ipl_bidder_details bd
        ON pts.bidder_id = bd.bidder_id)
        select * from lowest WHERE rank_l <4;
        

#Inferences- The top 3 ranks are bidder id 121,103,104
#The bottom 3 ranks are bidder id rank 1 - (102,109,116) rank 2-(119), rank 3-(105,122,128)

# ===============================================================================================================================================================
# ===============================================================================================================================================================