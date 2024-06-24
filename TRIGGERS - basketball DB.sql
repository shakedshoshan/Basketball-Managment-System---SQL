use basketballDB;

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


-- befor delete player, if he had team_id so decrise by 1 the player count in the same team
drop TRIGGER if exists befor_delete_player;
DELIMITER //

CREATE TRIGGER befor_delete_player
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


-- AFTER delete player, if he had team_id so decrise by 1 the player count in the same team
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