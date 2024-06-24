use basketballDB;

#######################  queiries  ###########################

-- List the players who have won individual trophies along with their names and trophy names:
SELECT h.first_name, h.last_name, t.trophy_name
FROM PlayerTrophy pt
JOIN Players p ON pt.player_id = p.player_id
JOIN Human h ON p.human_id = h.human_id
JOIN Trophy t ON pt.trophy_id = t.trophy_id
WHERE t.kind = 'personal';

-- List the competitions held in a specific country during a certain season:
SELECT comp.competition_name, s.season_id
FROM Competition comp
JOIN Season s ON comp.season_id = s.season_id
JOIN Countries co ON comp.country_id = co.country_id
WHERE co.country_name = 'United States';

-- Find the average fan count and loyalty rating for each team:
SELECT t.team_name, AVG(f.fan_count) AS avg_fan_count, AVG(f.loyalty_rating) AS avg_loyalty_rating
FROM Teams t
JOIN FanBase f ON t.team_id = f.team_id
GROUP BY t.team_name;

-- select all players on the specific team (roster)
SELECT p.player_id, h.first_name, h.last_name
FROM Players p
JOIN Human h ON p.human_id = h.human_id
WHERE p.team_id = 1;

-- List the top 3 countries with the highest total budget across all their teams:
SELECT C.country_name, SUM(T.budget) AS total_budget
FROM Countries AS C
JOIN Cities AS Ci ON C.country_id = Ci.country_id
JOIN Teams AS T ON Ci.city_id = T.city_id
GROUP BY C.country_name
ORDER BY total_budget DESC
LIMIT 3;


-- Retrieve the cities that have at least two teams competing in a specific competition:
SELECT Ci.city_name
FROM Cities AS Ci
JOIN Teams AS T ON Ci.city_id = T.city_id
WHERE T.team_id IN (
    SELECT team_id FROM Competition
    WHERE competition_id = 1 -- Replace with the desired competition_id
)
GROUP BY Ci.city_name
HAVING COUNT(DISTINCT T.team_id) >= 2;

-- Calculate the total number of trophies won by each country's teams:
SELECT C.country_name, SUM(TT.team_id) AS total_trophies
FROM Countries AS C
JOIN Cities AS Ci ON C.country_id = Ci.country_id
JOIN Teams AS T ON Ci.city_id = T.city_id
LEFT JOIN TeamTrophy AS TT ON T.team_id = TT.team_id
GROUP BY C.country_name;

-- Calculate the average number of players and the average budget per team in each country:
SELECT C.country_name, Ci.city_name, AVG(T.num_of_players) AS avg_players_per_team, AVG(T.budget) AS avg_budget_per_team
FROM Countries AS C
JOIN Cities AS Ci ON C.country_id = Ci.country_id
JOIN Teams AS T ON Ci.city_id = T.city_id
GROUP BY C.country_name, Ci.city_name;

-- Find the players who have an average rebound above 8 and have won more than 2 personal trophies:
SELECT H.first_name, H.last_name
FROM Human AS H
JOIN Players AS P ON H.human_id = P.human_id
JOIN PlayerTrophy AS PT ON P.player_id = PT.player_id
JOIN Trophy AS T ON PT.trophy_id = T.trophy_id
WHERE T.kind = 'personal'
GROUP BY H.first_name, H.last_name
HAVING AVG(P.average_rebound) > 8 AND COUNT(PT.trophy_id) >= 2;

-- List the cities that have hosted at least 3 games and have an average ticket price above 10:
SELECT Ci.city_name
FROM Cities AS Ci
JOIN Stadiums AS S ON Ci.city_id = S.city_id
JOIN Games AS G ON S.stadium_id = G.stadium_id
GROUP BY Ci.city_name
HAVING COUNT(G.game_id) >= 3
AND AVG(G.ticket_price) > 10;
