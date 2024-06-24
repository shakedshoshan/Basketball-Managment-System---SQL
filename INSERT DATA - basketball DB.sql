use basketballDB;

########################## INSERT DATA TO DATABASE ######################

-- Countries
INSERT INTO Countries (country_name, capacity, continental)
VALUES
    ('United States', 331002651, 'North America'),
    ('Brazil', 212559417, 'South America'),
    ('China', 1444216107, 'Asia'),
    ('Russia', 145934462, 'Europe'),
    ('South Africa', 59308690, 'Africa'),
	('India', 1380004385, 'Asia'),
    ('Mexico', 126190788, 'North America'),
    ('Germany', 83783942, 'Europe'),
    ('Australia', 25499884, 'Oceania'),
    ('Egypt', 102334404, 'Africa');

-- Cities
INSERT INTO Cities (city_name, capacity, country_id)
VALUES
    ('New York', 8419600, 1),
    ('Rio de Janeiro', 6718903, 2),
    ('Beijing', 21707000, 3),
    ('Moscow', 12692466, 4),
    ('Johannesburg', 957441, 5),
    ('Mumbai', 18414267, 6),
    ('Mexico City', 8918653, 7),
    ('Berlin', 3769495, 8),
    ('Sydney', 5312163, 9),
    ('Cairo', 10230350, 10);

-- Stadiums
INSERT INTO Stadiums (city_id, street, street_number, seating_capacity)
VALUES
    (1, 'Broadway', 123, 80000),
    (2, 'Copacabana', 456, 70000),
    (3, 'Olympic Blvd', 789, 90000),
    (4, 'Red Square', 101, 75000),
    (5, 'Lion''s Den', 111, 60000),
	(6, 'Gateway Blvd', 456, 75000),
    (7, 'Aztec Avenue', 789, 90000),
    (8, 'Waltz Street', 123, 60000),
    (9, 'Kangaroo Road', 101, 80000),
    (10, 'Pyramid Lane', 111, 65000);

-- Human
INSERT INTO Human (first_name, last_name, height, date_of_birth, monthly_salary, country_id, city_id)
VALUES
    ('John', 'Doe', 180.5, '1990-05-15',2000, 1, 1),
    ('Maria', 'Silva', 170.0, '1985-09-22', 2500, 2, 2),
    ('Li', 'Chen', 175.2, '1992-12-10',2000, 3, 3),
    ('Ivan', 'Petrov', 190.0,'1988-07-03',1000, 4, 4),
    ('Michael', 'Johnson', 190.0, '1993-05-12',3300, 2, 2),
    ('Thabo', 'Molefe', 185.7,'1995-02-28',25000, 5, 5),
    ('Sakura', 'Tanaka', 160.0, '1991-08-18',23000, 10, 10),
    ('Pedro', 'Rodriguez', 176.4, '1989-03-30',55000, 2, 2),
    ('Anna', 'Schmidt', 170.0, '1994-12-05',2000, 9, 9),
    ('Liam', 'Johnson', 195.2, '1997-06-25',8000, 10,10),
    ('Ahmed', 'Ali', 180.1, '1990-11-12',20000, 2, 2);

-- Coaches
INSERT INTO Coaches (coach_id, num_of_trophy)
VALUES
    (1, 3),
    (2, 2),
    (3, 1),
    (4, 4),
    (5, 2),
    (6, 0),
    (7, 1),
    (8, 3),
    (9, 2),
    (10, 4);

-- Teams
INSERT INTO Teams ( team_name, budget, num_of_players, num_of_trophies, coach_id, stadium_id, city_id)
VALUES
    ('New York FC', 5000000.00, 25, 8, 1, 1,1),
    ('Rio United', 3500000.00, 22, 5, 2, 2,2),
    ('Beijing Dragons', 7000000.00, 28, 10, 3, 2,2),
    ('Moscow Bears', 4500000.00, 26, 7, 4, 4,4),
    ('Joburg Lions', 3000000.00, 20, 3, 5, 5,5),
	('Los Angeles Stars', 4000000.00, 24, 6, 6, 6, 6),
    ('Sao Paulo Strikers', 3000000.00, 18, 4, 7, 1, 1),
    ('Tokyo Titans', 6000000.00, 26, 9, 8, 2, 2),
    ('Berlin Thunder', 3800000.00, 23, 7, 9, 1, 1),
    ('Sydney Waves', 2500000.00, 16, 2, 10, 1, 1);

-- Players
INSERT INTO Players (player_id, human_id, team_id, average_points, average_assist, average_rebound, position, num_of_trophy)
VALUES
    (1,1, 1, 12.5, 5.2, 8.7, 4, 0),
    (2,2, 1, 10.8, 6.3, 5.9, 2, 0),
    (3,3, 3, 15.1, 7.8, 6.5, 3, 0),
    (4,4, 4, 9.7, 4.5, 10.2, 5, 0),
    (5,5, 5, 7.2, 3.8, 4.1, 1, 0),
    (6, 6, 6, 11.8, 4.7, 7.3, 3, 0),
    (7, 7, 7, 9.5, 6.0, 4.2, 2, 0),
    (8, 8, 8, 14.2, 8.5, 5.8, 5, 0),
    (9, 9, 9, 10.1, 4.2, 9.9, 1, 0),
    (10, 10, 10, 8.7, 3.6, 3.9, 4, 0);

-- Referees
INSERT INTO Referees (referee_id, organization_name, rank_points)
VALUES
    (1, 'International Referee Association', 200),
    (2, 'Asian Referees Federation', 170),
    (4, 'European Referees Union', 220),
    (7, 'Oceanic Referees Group', 140),
    (10, 'Asian Football Umpires', 190);

-- Season
INSERT INTO Season (season_id)
VALUES
    (2023),
    (2024),
    (2025),
    (2026),
    (2027);

-- Competition
INSERT INTO Competition (competition_id, competition_name, num_of_teams, winner_prize, country_id, season_id)
VALUES
    (1, 'National Championship', 10, 50000.00, 1,2023),
    (2, 'International Cup', 16, 100000.00, 2,2023),
    (3, 'Regional Tournament', 8, 25000.00, null,2023),
    (4, 'Continental League', 12, 75000.00, 4,2024),
    (5, 'Global d Championship', 20, 150000.00, 5,2024),
    (6,'National t Championship', 10, 50000.00, 1,2024),
    (7, 'International k Cup', 16, 100000.00, 2,2024),
    (8, 'Regional p Tournament', 8, 25000.00, 3,2025),
    (9, 'Continental n League', 12, 75000.00, 4,2026),
    (10, 'Global u Championship', 20, 150000.00, 5,2027);
    
    
-- Trophy
INSERT INTO Trophy (trophy_name, cost_of_manufacturing, kind)
VALUES
    ('Championship Cup', 10000.00, 'collective'),
    ('MVP Award', 500.00, 'personal'),
    ('Golden Boot', 750.00, 'personal'),
    ('Fair Play Trophy', 1000.00, 'collective'),
    ('League Cup', 8000.00, 'collective'),
    ('Championship Cup', 10000.00, 'collective'),
    ('Championship Cup MVP', 100.00, 'personal'),
    ('MVP Award', 500.00, 'personal'),
    ('Golden Boot', 750.00, 'personal'),
    ('Fair Play Trophy', 1000.00, 'collective');



    

-- StandingTable
INSERT INTO StandingTable (team_id, competition_id, team_points)
VALUES
    (1, 1, 75),
    (2, 2, 69),
    (3, 2, 64),
    (4, 4, 60),
    (7, 1, 60),
    (5, 5, 57),
    (9, 1, 75),
    (10, 1, 60);

-- FanBase
INSERT INTO FanBase (fan_count, loyalty_rating, performance_rating, avg_money_spent, team_id)
VALUES
    (50000, 4, 5, 50.00, 1),
    (42000, 3, 4, 40.00, 2),
    (55000, 5, 5, 60.00, 3),
    (35000, 2, 3, 35.00, 4),
    (28000, 3, 3, 30.00, 5);
    
-- Injuries
INSERT INTO Injuries (injury_name, return_date, player_id)
VALUES
    ('Ankle Sprain', '2023-08-20', 1),
    ('Hamstring Strain', '2023-09-05', 3),
    ('Knee Injury', '2024-01-15', 5),
    ('Groin Pull', '2023-08-25', 2),
    ('Shoulder Dislocation', '2024-03-10', 4);
    
    
-- Call the AddTeamTrophy 

CALL AddTeamTrophy(2, 4, 5);
CALL AddTeamTrophy(2, 4, 4);
CALL AddTeamTrophy(3, 6,5);
CALL AddTeamTrophy(1, 1, 4);
CALL AddTeamTrophy(1, 5, 5);
CALL AddTeamTrophy(1, 1,1);


INSERT INTO playertrophy (player_id, trophy_id, competition_id)
VALUES (1, 8,2), (2, 8,2),(1,3,2);


INSERT INTO Games (referee_id, game_date, ticket_price, stadium_id, team_home_id, team_guese_id, competition_id) 
VALUES (2, '2023-09-27', 10.0, 1, 1, 10, 1);
INSERT INTO Games (referee_id, game_date,  ticket_price, stadium_id, team_home_id, team_guese_id, competition_id) 
VALUES (2, '2023-08-27', 10.0, 1, 1, 9, 1);
INSERT INTO Games (referee_id, game_date, ticket_price, stadium_id, team_home_id, team_guese_id, competition_id) 
VALUES (2, '2023-09-20', 10.0, 1, 2, 3, 2);
INSERT INTO Games (referee_id, game_date,  ticket_price, stadium_id, team_home_id, team_guese_id, competition_id) 
VALUES (2, '2013-09-20', 10.0, 1, 2, 3, 2);
INSERT INTO Games (referee_id, game_date, ticket_price, stadium_id, team_home_id, team_guese_id, competition_id) 
VALUES (2, '2015-09-20', 25.0, 1, 2, 3, 2);


CALL InsertScoreAndStanding(1,100,96,15000);