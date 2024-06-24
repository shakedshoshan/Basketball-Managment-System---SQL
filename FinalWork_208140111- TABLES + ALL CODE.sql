# ID_208140111
drop schema if exists basketballDB;
create schema basketballDB;
use basketballDB;

-- Create tables

CREATE TABLE Countries (
    country_id INT NOT NULL auto_increment PRIMARY KEY,
    country_name VARCHAR(50),
    capacity INT,
    continental VARCHAR(50)
);

CREATE TABLE Cities (
    city_id INT NOT NULL auto_increment PRIMARY KEY,
    city_name VARCHAR(50),
    capacity INT,
    country_id INT,
    FOREIGN KEY (country_id) REFERENCES Countries(country_id) ON DELETE CASCADE
);

CREATE TABLE Stadiums (
    stadium_id INT NOT NULL auto_increment PRIMARY KEY,
    city_id INT,
    street VARCHAR(50),
    street_number INT,
    seating_capacity INT,
    FOREIGN KEY (city_id) REFERENCES Cities(city_id)
);

CREATE TABLE Human (
    human_id INT NOT NULL auto_increment PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    height DECIMAL(5, 2),
    date_of_birth DATE,
    monthly_salary INT,
    country_id INT,
    city_id INT,
    FOREIGN KEY (country_id) REFERENCES Countries(country_id),
    FOREIGN KEY (city_id) REFERENCES Cities(city_id)
);

CREATE TABLE Coaches (
    coach_id INT NOT NULL PRIMARY KEY,
    num_of_trophy INT DEFAULT(0),
    FOREIGN KEY (coach_id) REFERENCES Human(human_id) ON DELETE CASCADE 
);

CREATE TABLE Teams (
    team_id INT NOT NULL auto_increment PRIMARY KEY,
    team_name VARCHAR(100),
    budget DECIMAL(25, 2),
    num_of_players INT DEFAULT(0),
    num_of_trophies INT DEFAULT(0),
    coach_id INT ,
    stadium_id INT,
    city_id INT,
    FOREIGN KEY (coach_id) REFERENCES Coaches(coach_id),
    FOREIGN KEY (stadium_id) REFERENCES Stadiums(stadium_id),
    FOREIGN KEY (city_id) REFERENCES Cities(city_id)
);

CREATE TABLE Players (
    player_id INT NOT NULL auto_increment PRIMARY KEY,
    human_id INT NOT NULL,
    team_id INT,
    average_points DECIMAL(4, 2) DEFAULT(0.0),
    average_assist DECIMAL(4, 2) DEFAULT(0.0),
    average_rebound DECIMAL(5, 2) DEFAULT(0.0),
    position INT CHECK (position >= 1 AND position <= 5),
    num_of_trophy INT,
    FOREIGN KEY (player_id) REFERENCES Human(human_id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES Teams(team_id) 
);


CREATE TABLE Referees (
    referee_id INT NOT NULL PRIMARY KEY,
    organization_name VARCHAR(100),
    rank_points INT DEFAULT(0),
    FOREIGN KEY (referee_id) REFERENCES Human(human_id) ON DELETE CASCADE
);

CREATE TABLE Season (
    season_id YEAR NOT NULL PRIMARY KEY
);


CREATE TABLE Competition (
    competition_id INT NOT NULL auto_increment PRIMARY KEY,
    competition_name VARCHAR(100),
    num_of_teams INT DEFAULT(0),
    winner_prize DECIMAL(15, 2),
    country_id INT,
    season_id YEAR NOT NULL,
    FOREIGN KEY (country_id) REFERENCES Countries(country_id),
    FOREIGN KEY (season_id) REFERENCES Season(season_id) ON DELETE CASCADE
);

CREATE TABLE Trophy (
	trophy_id INT NOT NULL auto_increment PRIMARY KEY,
    trophy_name VARCHAR(100),
    cost_of_manufacturing DECIMAL(10, 2),
    kind VARCHAR(10) CHECK (kind IN ('collective', 'personal'))
);


CREATE TABLE Games (
    game_id INT NOT NULL auto_increment PRIMARY KEY,
    referee_id INT DEFAULT(NULL),
    game_date DATE,
    ticket_price DECIMAL(10, 2) DEFAULT(5.0),
    stadium_id INT NOT NULL,
    team_home_id INT NOT NULL,
    team_guese_id INT NOT NULL,
    competition_id INT,
    FOREIGN KEY (referee_id) REFERENCES Referees(referee_id),
    FOREIGN KEY (stadium_id) REFERENCES Stadiums(stadium_id),
    FOREIGN KEY (team_home_id) REFERENCES Teams(team_id) ON DELETE CASCADE,
    FOREIGN KEY (team_guese_id) REFERENCES Teams(team_id) ON DELETE CASCADE,
    FOREIGN KEY (competition_id) REFERENCES Competition(competition_id)
);

CREATE TABLE Score (
    game_id INT NOT NULL,
    score_home INT,
    score_guest INT,
    arrived_count INT DEFAULT(NULL),
    FOREIGN KEY (game_id) REFERENCES Games(game_id) ON DELETE CASCADE
);


CREATE TABLE StandingTable (
    team_id INT,
    competition_id INT NOT NULL,
    team_points INT NOT NULL,
    FOREIGN KEY (team_id) REFERENCES Teams(team_id) ON DELETE CASCADE,
    FOREIGN KEY (competition_id) REFERENCES Competition(competition_id) ON DELETE CASCADE
);

CREATE TABLE FanBase (
    fan_count INT,
    loyalty_rating INT CHECK (loyalty_rating >= 0 AND loyalty_rating <= 10 ),
    performance_rating INT CHECK (performance_rating >= 0 AND performance_rating <= 10 ),
    avg_money_spent DECIMAL(10, 2),
    team_id INT NOT NULL,
    FOREIGN KEY (team_id) REFERENCES Teams(team_id) ON DELETE CASCADE
);

CREATE TABLE Injuries (
    injury_name VARCHAR(100),
    return_date DATE,
    player_id INT,
    FOREIGN KEY (player_id) REFERENCES Players(player_id) ON DELETE CASCADE
);


CREATE TABLE PlayerTrophy (
    player_id INT,
    trophy_id INT,
    competition_id INT NOT NULL,
    PRIMARY KEY (player_id, trophy_id,competition_id),
    FOREIGN KEY (player_id) REFERENCES Players(player_id) ON DELETE CASCADE,
    FOREIGN KEY (trophy_id) REFERENCES Trophy(trophy_id) ON DELETE CASCADE,
    FOREIGN KEY (competition_id) REFERENCES Competition(competition_id) ON DELETE CASCADE
);

CREATE TABLE CoachTrophy (
    coach_id INT,
    trophy_id INT,
    competition_id INT NOT NULL,
    PRIMARY KEY (coach_id, trophy_id,competition_id),
    FOREIGN KEY (coach_id) REFERENCES Coaches(coach_id) ON DELETE CASCADE,
    FOREIGN KEY (trophy_id) REFERENCES Trophy(trophy_id) ON DELETE CASCADE,
    FOREIGN KEY (competition_id) REFERENCES Competition(competition_id) ON DELETE CASCADE
);

CREATE TABLE TeamTrophy (
    team_id INT NOT NULL,
    trophy_id INT NOT NULL,
    competition_id INT NOT NULL,
    PRIMARY KEY (team_id, trophy_id,competition_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id) ON DELETE CASCADE,
    FOREIGN KEY (trophy_id) REFERENCES Trophy(trophy_id) ON DELETE CASCADE,
    FOREIGN KEY (competition_id) REFERENCES Competition(competition_id) ON DELETE CASCADE
);

CREATE TABLE competitionTrophy (
    competition_id INT NOT NULL,
    trophy_id INT NOT NULL,
    PRIMARY KEY (competition_id, trophy_id),
    FOREIGN KEY (trophy_id) REFERENCES Trophy(trophy_id) ON DELETE CASCADE,
    FOREIGN KEY (competition_id) REFERENCES Competition(competition_id) ON DELETE CASCADE
);


############### PROCEDURES #################


-- team winning a competiton
drop PROCEDURE if exists AddTeamTrophy;
DELIMITER //

CREATE PROCEDURE AddTeamTrophy(
    IN p_team_id INT,
    IN p_trophy_id INT,
    IN p_competition_id INT
)
BEGIN
    DECLARE p_coach_id INT;
    DECLARE winner_prize_to_add DECIMAL(25, 2);
    DECLARE current_budget DECIMAL(25, 2);
    DECLARE sum_budget DECIMAL(25, 2);


    -- insert competitionTrophy
    INSERT INTO competitionTrophy (competition_id, trophy_id)
    VALUES (p_competition_id, p_trophy_id);
    
    -- Insert the trophy for the team
    INSERT INTO TeamTrophy (team_id, trophy_id, competition_id)
    VALUES (p_team_id, p_trophy_id, p_competition_id);

	-- Update team's trophy count
	UPDATE Teams
	SET num_of_trophies = num_of_trophies + 1
	WHERE team_id = p_team_id;

	-- Update player's trophy count
	UPDATE Players
	SET num_of_trophy = num_of_trophy + 1
	WHERE team_id = p_team_id;

	-- Update coach's trophy count
	SELECT coach_id INTO p_coach_id FROM Teams WHERE team_id = p_team_id;
	UPDATE Coaches
	SET num_of_trophy = num_of_trophy + 1
	WHERE coach_id = p_coach_id;
    
    -- Add the trophy for PlayerTrophy
    INSERT INTO PlayerTrophy (player_id, trophy_id, competition_id)
    SELECT player_id, p_trophy_id, p_competition_id FROM Players WHERE team_id = p_team_id;

    -- Add the trophy for CoachTrophy
    INSERT INTO CoachTrophy (coach_id, trophy_id, competition_id)
    SELECT coach_id, p_trophy_id, p_competition_id FROM Coaches
    WHERE coach_id = (SELECT coach_id FROM Teams WHERE team_id = p_team_id);
    
    
    -- Update fan_count and avg_money_spent in FanBase
    UPDATE FanBase
    SET fan_count = fan_count * 1.3, avg_money_spent = avg_money_spent * 1.1
    WHERE team_id = p_team_id;

    -- Update the budget of team after win prize
    -- get winner prize
    SELECT winner_prize INTO winner_prize_to_add
    FROM Competition
    WHERE competition_id = p_competition_id;
    
    SELECT budget INTO current_budget
    FROM Teams as t
    WHERE t.team_id = p_team_id;
    
    SET sum_budget = current_budget + winner_prize_to_add;
    
    UPDATE Teams as t
    SET t.budget = sum_budget
    WHERE t.team_id = p_team_id;

END //

DELIMITER ;

-- transfer money between teams
drop PROCEDURE if exists TransferBudget;
DELIMITER //
CREATE PROCEDURE TransferBudget(
    IN from_team_id INT,
    IN to_team_id INT,
    IN transfer_amount DECIMAL(25, 2)
)
BEGIN
    DECLARE from_team_budget DECIMAL(25, 2);
    DECLARE to_team_budget DECIMAL(25, 2);
    
    -- Get budgets of the two teams
    SELECT budget INTO from_team_budget
    FROM Teams
    WHERE team_id = from_team_id;
    
    SELECT budget INTO to_team_budget
    FROM Teams
    WHERE team_id = to_team_id;
    
    -- Ensure that the transfer amount is not greater than the from_team's budget
    IF from_team_budget >= transfer_amount THEN
        -- Perform the budget transfer
        UPDATE Teams
        SET budget = budget - transfer_amount
        WHERE team_id = from_team_id;
        
        UPDATE Teams
        SET budget = budget + transfer_amount
        WHERE team_id = to_team_id;
        
        
        SELECT 'Budget transferred successfully' AS message;
    ELSE
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient budget in the source team';
        #SELECT 'Insufficient budget in the source team' AS message;
    END IF;
    
END;
//
DELIMITER ;

#CALL TransferBudget(1, 2, NULL);

-- player transfer
drop PROCEDURE if exists TransferPlayerBetweenTeams;
DELIMITER //
CREATE PROCEDURE TransferPlayerBetweenTeams(
    IN player_id_to_transfer INT,
    IN new_team_id INT,
    IN transfer_money DECIMAL(25, 2)
)
BEGIN
    DECLARE current_team_id INT;
    DECLARE old_num_of_players INT;
    DECLARE new_num_of_players INT;

    -- Get the current team of the player
    SELECT team_id INTO current_team_id
    FROM Players
    WHERE player_id = player_id_to_transfer;
    
    CALL TransferBudget(current_team_id, new_team_id, transfer_money);

    -- Update the number of players in the current team
    UPDATE Teams
    SET num_of_players = num_of_players - 1
    WHERE team_id = current_team_id;

    -- Update the team for the player
    UPDATE Players
    SET team_id = new_team_id
    WHERE player_id = player_id_to_transfer;

    -- Update the number of players in the new team
    SELECT num_of_players INTO old_num_of_players
    FROM Teams
    WHERE team_id = new_team_id;

    SET new_num_of_players = old_num_of_players + 1;

    UPDATE Teams
    SET num_of_players = new_num_of_players
    WHERE team_id = new_team_id;
    
    
END;
//
DELIMITER ;

#CALL TransferPlayerBetweenTeams(1, 2,10000000000000);

-- transfer coach
drop PROCEDURE if exists TransferCoachBetweenTeams;
DELIMITER //
CREATE PROCEDURE TransferCoachBetweenTeams(
    IN coach_id_to_transfer INT,
    IN new_team_id INT,
    IN transfer_money DECIMAL(25, 2)
)
BEGIN
    DECLARE current_team_id INT;

    -- Get the current team of the coach
    SELECT team_id INTO current_team_id
    FROM Teams
    WHERE coach_id = coach_id_to_transfer;
    
    CALL TransferBudget(current_team_id, new_team_id, transfer_money);
    
    -- Update the old team for the coach
    UPDATE Teams
    SET coach_id = NULL
    WHERE team_id = current_team_id;

    -- Update the team for the coach
    UPDATE Teams
    SET coach_id = coach_id_to_transfer
    WHERE team_id = new_team_id;
    
    

END;
//
DELIMITER ;

#CALL TransferCoachBetweenTeams(1,2,1);
#CALL TransferCoachBetweenTeams(2,0);



-- see a standing table by competiton
drop PROCEDURE if exists GetTeamsByCompetition;
DELIMITER //

CREATE PROCEDURE GetTeamsByCompetition(IN competition_id INT)
BEGIN
    SELECT t.team_name, st.team_points
    FROM Teams AS t
    JOIN StandingTable AS st ON t.team_id = st.team_id
    WHERE st.competition_id = competition_id
    ORDER BY st.team_points DESC;
END;

//
DELIMITER ;

#CALL GetTeamsByCompetition(1);


-- find available refeeres in a specific date
drop PROCEDURE if exists GetAvailableReferees;
DELIMITER //

CREATE PROCEDURE GetAvailableReferees(IN game_date DATE)
BEGIN
    SELECT R.referee_id
    FROM Referees AS R
    WHERE R.referee_id NOT IN (
        SELECT DISTINCT G.referee_id
        FROM Games AS G
        WHERE G.game_date = game_date
    );
END;

//

DELIMITER ;

#CALL GetAvailableReferees('2023-08-27');


-- update player stat
drop PROCEDURE if exists update_player_stats;
DELIMITER //

CREATE PROCEDURE update_player_stats(
    IN player_id_param INT,
    IN new_average_points DECIMAL(4, 2),
    IN new_average_assist DECIMAL(4, 2),
    IN new_average_rebound DECIMAL(5, 2)
)
BEGIN
    UPDATE Players
    SET average_points = new_average_points,
        average_assist = new_average_assist,
        average_rebound = new_average_rebound
    WHERE player_id = player_id_param;
END;
//

DELIMITER ;

#CALL update_player_stats(1, 25.2, 6.5, 8.7);


-- set a score, total people arrived and point in table
drop PROCEDURE if exists InsertScoreAndStanding;
DELIMITER //

CREATE PROCEDURE InsertScoreAndStanding(
	IN p_game_id INT,
	IN p_score_home INT,
	IN p_score_guest INT,
	IN p_arrived_count INT
    )
BEGIN
    DECLARE competition INT;
    DECLARE team_home INT;
    DECLARE team_guese INT;
    
    INSERT INTO Score (game_id, score_home, score_guest, arrived_count)
    VALUES (p_game_id, p_score_home, p_score_guest,p_arrived_count);

	-- get competition id
    SELECT competition_id INTO competition FROM Games WHERE game_id = p_game_id;
    
    -- get teams id
    SELECT team_home_id INTO team_home FROM Games WHERE game_id = p_game_id;
    SELECT team_guese_id INTO team_guese FROM Games WHERE game_id = p_game_id;

	-- check the winner and set points on table
    IF p_score_home > p_score_guest THEN
        -- Home team wins
        UPDATE StandingTable SET team_points = team_points + 2 
        WHERE team_id = team_home AND competition_id = competition;
        
        UPDATE StandingTable SET team_points = team_points + 1 
        WHERE team_id = team_guese AND competition_id = competition;
    ELSEIF p_score_home < p_score_guest THEN
        -- Guest team wins
        UPDATE StandingTable SET team_points = team_points + 1 
        WHERE team_id = team_home AND competition_id = competition;
        
        UPDATE StandingTable SET team_points = team_points + 2 
        WHERE team_id = team_guese AND competition_id = competition;
    END IF;
END;
//

DELIMITER ;


#################### TRIGGERS ####################

-- update number of players after add new player to team
drop TRIGGER if exists IncrementPlayerCount;

DELIMITER //

CREATE TRIGGER IncrementPlayerCount
AFTER INSERT ON Players
FOR EACH ROW
BEGIN
    -- Increment the num_of_players count for the team
    UPDATE Teams
    SET num_of_players = num_of_players + 1
    WHERE team_id = NEW.team_id;
END;

//

DELIMITER ;


-- check for "collective" trophy for team 
drop TRIGGER if exists AlertTeamPersonalTrophy;
DELIMITER //
CREATE TRIGGER AlertTeamPersonalTrophy
AFTER INSERT ON TeamTrophy
FOR EACH ROW
BEGIN
    DECLARE team_trophy_kind VARCHAR(10);

    -- Get the kind of trophy associated with the team
    SELECT tr.kind INTO team_trophy_kind
    FROM Trophy tr
    WHERE tr.trophy_id = NEW.trophy_id;

    -- Check if the trophy being added is a "personal" trophy and raise an error if true
    IF team_trophy_kind = 'personal' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Team cannot win a "personal" trophy.';
    END IF;
END;
//
DELIMITER ;


#CALL AddTeamTrophy(1, 3, 3);
#CALL AddTeamTrophy(1, 2, 2023);




-- check teams for same competiton
drop TRIGGER if exists check_same_competition;
DELIMITER //
CREATE TRIGGER check_same_competition
AFTER INSERT ON Games
FOR EACH ROW
BEGIN
    DECLARE home_competition INT;
    DECLARE guest_competition INT;

    SELECT competition_id INTO home_competition FROM standingtable WHERE team_id = NEW.team_home_id;
    SELECT competition_id INTO guest_competition FROM standingtable WHERE team_id = NEW.team_guese_id;

    IF home_competition != NEW.competition_id OR guest_competition != NEW.competition_id  THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'One or both of the teams do not have a valid competition.';
    END IF;
END;
//
DELIMITER ;


#INSERT INTO Games (referee_id, game_date, stadium_id, team_home_id, team_guese_id, competition_id) 
#VALUES (1, '2023-01-27', 1, 1, 2, 1);


--  check teams and refeere availability by date
drop TRIGGER if exists check_game_availability;
DELIMITER //

CREATE TRIGGER check_game_availability
BEFORE INSERT ON Games
FOR EACH ROW
BEGIN
-- check for no duplicate game
    IF EXISTS (
        SELECT 1
        FROM Games
        WHERE game_date = NEW.game_date
            AND (team_home_id = NEW.team_home_id OR team_guese_id = NEW.team_guese_id)
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'One of the teams already has a game on the same date.';
    END IF;
    
-- check the available of the refeere
    IF EXISTS (
        SELECT 1
        FROM Games
        WHERE game_date = NEW.game_date AND referee_id = NEW.referee_id
    ) THEN
        -- The referee already has another game on the same date, prevent insertion
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The referee already has another game on the same date.';
    END IF;
END;
//

DELIMITER ;


/*
INSERT INTO Games (referee_id, game_date, stadium_id, team_home_id, team_guese_id, competition_id) 
VALUES ( 2, '2023-06-17', 1, 10, 9, 1); # legall

INSERT INTO Games (referee_id, game_date, stadium_id, team_home_id, team_guese_id, competition_id) 
VALUES ( 1, '2023-06-17', 1, 10, 1, 1); # not available team (10)

INSERT INTO Games (referee_id, game_date, stadium_id, team_home_id, team_guese_id, competition_id) 
VALUES ( 2, '2023-06-17', 1, 7, 1, 1); # not available refeere
*/


-- check if player in legal age
drop TRIGGER if exists check_player_age;
DELIMITER //

CREATE TRIGGER check_player_age
BEFORE INSERT ON Players
FOR EACH ROW
BEGIN
    DECLARE player_dob DATE;
    DECLARE player_age INT;
    
    SELECT date_of_birth INTO player_dob
    FROM Human
    WHERE human_id = NEW.human_id;
    
    -- Calculate the player's age based on the date of birth
    SET player_age = TIMESTAMPDIFF(YEAR, player_dob, CURDATE());
    
    IF player_age < 18 THEN
        -- Player is not above 18 years old, prevent insertion
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Player must be at least 18 years old to be inserted.';
    END IF;
END;
//

DELIMITER ;



#INSERT INTO Human (human_id, first_name, last_name, height, city, country, date_of_birth, country_id, city_id)
#VALUES (8, 'Jon', 'loe', 180.5, 'New Amsterdam', 'ISRAEL', '2010-05-15', 1, 1);


#INSERT INTO Players (player_id, human_id, team_id, average_points, average_assist, average_rebound, position, num_of_trophy)
#VALUES (6,6, 1, 10.5, 4.2, 5.8, 2, 2);



-- calculate profits from games
drop TRIGGER if exists UpdateBudgetAfterGameInsert;
DELIMITER //
CREATE TRIGGER UpdateBudgetAfterGameInsert
AFTER INSERT ON Score
FOR EACH ROW
BEGIN
    DECLARE current_ticket_price DECIMAL(10, 2);
    DECLARE current_home_team_id INT;
    DECLARE current_guese_team_id INT;
    DECLARE current_arrived_count INT;
    DECLARE budget_increase_home DECIMAL(25, 2);
    DECLARE budget_increase_guese DECIMAL(25, 2);
    
    -- Get the home team ID, ticket price and arrived count for the inserted game
    SELECT team_home_id, team_guese_id, ticket_price INTO current_home_team_id, current_guese_team_id, current_ticket_price
    FROM Games
    WHERE game_id = NEW.game_id;
    
    -- Get the ticket price  inserted game
    SELECT arrived_count INTO current_arrived_count
    FROM Score
    WHERE game_id = NEW.game_id;
    
    -- Calculate the budget increase based on the formula(80% go to home team 20% to guese team and 17% tax)
    SET budget_increase_home = (current_arrived_count * current_ticket_price * 0.83 * 0.8);
    SET budget_increase_guese = (current_arrived_count * current_ticket_price * 0.83 * 0.2);
    
    -- Update the home team's budget
    UPDATE Teams
    SET budget = budget + budget_increase_home
    WHERE team_id = current_home_team_id;
    
    -- Update the guese team's budget
    UPDATE Teams
    SET budget = budget + budget_increase_guese
    WHERE team_id = current_guese_team_id;
    
END;
//
DELIMITER ;


#INSERT INTO Games (game_id, referee_id, game_date, arrived_count, ticket_price, city_id, team_home_id, team_guese_id, competition_id) 
#VALUES (8, 2, '2023-09-27', 15000, 10.0, 1, 1, 3, 1);

-- check coach availability
drop TRIGGER if exists before_team_insert;
DELIMITER //
CREATE TRIGGER before_team_insert
BEFORE INSERT ON Teams
FOR EACH ROW
BEGIN
    DECLARE coach_count INT;
    
    -- Check if the coach_id already exists in another team
    SELECT COUNT(*) INTO coach_count
    FROM Teams
    WHERE coach_id = NEW.coach_id;
    
    IF coach_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Coach is already assigned to another team';
    END IF;
END;
//
DELIMITER ;

#INSERT INTO Teams (team_name, budget, num_of_players, num_of_trophies, coach_id, stadium_id, city_id)
#VALUES ('New York Yunkkiz', 5500000.00, 15, 23, NULL, 2,1);


-- check if team in competition on same country, if country in competition is null so it is global competition
drop TRIGGER if exists check_country_consistency;

DELIMITER //
CREATE TRIGGER check_country_consistency
AFTER INSERT ON StandingTable
FOR EACH ROW
BEGIN
    DECLARE competition_country_id INT;
    DECLARE team_country_id INT;
    
    -- Get the country_id of the competition
    SELECT country_id INTO competition_country_id
    FROM Competition
    WHERE competition_id = NEW.competition_id;
    
    -- Check if there's a competition_country_id and the team's country_id is not NULL
    IF competition_country_id IS NOT NULL AND NEW.team_id IS NOT NULL THEN
        
        -- Get the country_id of the team's city
        SELECT c.country_id INTO team_country_id
        FROM Cities c
        JOIN Teams t ON c.city_id = t.city_id
        WHERE t.team_id = NEW.team_id;
        
        -- Check if the team's country_id is different from the competition's country_id
        IF team_country_id <> competition_country_id THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Team and competition are from different countries';
        END IF;
    END IF;
    
END;
//
DELIMITER ;

#INSERT INTO StandingTable (team_id, competition_id, team_points) # legal
#VALUES (1, 1, 75);
#INSERT INTO StandingTable (team_id, competition_id, team_points) #illegal
#VALUES (2, 1, 69);
#INSERT INTO StandingTable (team_id, competition_id, team_points) #llegal
#VALUES (2, 3, 69);

-- AFTER delete player, if he had team_id so reduce by 1 the player count in the same team
drop TRIGGER if exists AFTER_delete_player;
DELIMITER //

CREATE TRIGGER AFTER_delete_player
AFTER DELETE ON Players
FOR EACH ROW
BEGIN
    DECLARE team_id_var INT;
    
     -- Delete corresponding injury record, if exists
    -- DELETE FROM Injuries WHERE player_id = 1;
    
    -- Get the team_id of the deleted player
    SET team_id_var = OLD.team_id;
    
    -- Decrease the num_of_players count in the team
    UPDATE Teams
    SET num_of_players = num_of_players - 1
    WHERE team_id = team_id_var;
END;

//

DELIMITER ;

#delete from players where player_id = 1;

-- before delete a team Set the team_id of players to NULL
drop TRIGGER if exists before_delete_team;
DELIMITER //

CREATE TRIGGER before_delete_team
BEFORE DELETE ON Teams
FOR EACH ROW
BEGIN
    
    UPDATE Players
    SET team_id = NULL
    WHERE team_id = OLD.team_id;

END;
//

DELIMITER ;

#delete from teams where team_id = 1;

-- before delete coach
drop TRIGGER if exists before_delete_coach;
DELIMITER //

CREATE TRIGGER before_delete_coach
BEFORE DELETE ON Coaches
FOR EACH ROW
BEGIN
    
    UPDATE Teams
    SET coach_id = NULL
    WHERE coach_id = OLD.coach_id;
    

END;
//

DELIMITER ;

#delete from Coaches where coach_id = 3

-- before delete city
drop TRIGGER if exists before_delete_city;
DELIMITER //

CREATE TRIGGER before_delete_city
BEFORE DELETE ON Cities
FOR EACH ROW
BEGIN
    -- Set city references to NULL in Human table
    UPDATE Human
    SET city_id = NULL
    WHERE city_id = OLD.city_id;

    -- Set city references to NULL in Stadiums table
    UPDATE Stadiums
    SET city_id = NULL
    WHERE city_id = OLD.city_id;

    -- Set city references to NULL in Teams table
    UPDATE Teams
    SET city_id = NULL
    WHERE city_id = OLD.city_id;
END;
//

DELIMITER ;

#delete from Cities where city_id = 1;


-- recalculte team budget after update competition
drop TRIGGER if exists before_update_competition;
DELIMITER //

CREATE TRIGGER before_update_competition
BEFORE UPDATE ON Competition
FOR EACH ROW
BEGIN
    DECLARE old_winner_prize DECIMAL(15, 2);
    DECLARE new_winner_prize DECIMAL(15, 2);
    DECLARE winner_team_id INT;
    DECLARE done INT DEFAULT 0;

    -- Get the winner team_id for the competition
	DECLARE cur CURSOR FOR
		SELECT team_id
		FROM TeamTrophy
		WHERE competition_id = OLD.competition_id AND trophy_id
        IN (SELECT trophy_id FROM Trophy WHERE kind = 'collective');
        
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
	
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO winner_team_id;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Reduce the old winner_prize from the winner team's budget
        UPDATE Teams
        SET budget = budget - OLD.winner_prize
        WHERE team_id = winner_team_id;

        -- Add the new winner_prize to the new winner team's budget
        UPDATE Teams
        SET budget = budget + NEW.winner_prize
        WHERE team_id = winner_team_id;
    END LOOP;

    CLOSE cur;
END;
//

DELIMITER ;


#UPDATE Competition SET winner_prize = 0 WHERE competition_id = 5;
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
INSERT INTO Cities (city_id, city_name, capacity, country_id)
VALUES
    (1, 'New York', 8419600, 1),
    (2, 'Rio de Janeiro', 6718903, 2),
    (3, 'Beijing', 21707000, 3),
    (4, 'Moscow', 12692466, 4),
    (5, 'Johannesburg', 957441, 5),
    (6, 'Mumbai', 18414267, 6),
    (7, 'Mexico City', 8918653, 7),
    (8, 'Berlin', 3769495, 8),
    (9, 'Sydney', 5312163, 9),
    (10, 'Cairo', 10230350, 10);

-- Stadiums
INSERT INTO Stadiums (stadium_id, city_id, street, street_number, seating_capacity)
VALUES
    (1, 1, 'Broadway', 123, 80000),
    (2, 2, 'Copacabana', 456, 70000),
    (3, 3, 'Olympic Blvd', 789, 90000),
    (4, 4, 'Red Square', 101, 75000),
    (5, 5, 'Lion''s Den', 111, 60000),
	(6, 6, 'Gateway Blvd', 456, 75000),
    (7, 7, 'Aztec Avenue', 789, 90000),
    (8, 8, 'Waltz Street', 123, 60000),
    (9, 9, 'Kangaroo Road', 101, 80000),
    (10, 10, 'Pyramid Lane', 111, 65000);

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




#CALL InsertScoreAndStanding(1,100,96,15000);

#######################  queiries  ###########################
/*
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


