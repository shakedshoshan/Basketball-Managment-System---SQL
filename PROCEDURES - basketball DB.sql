use basketballDB;

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
    
    CALL TransferBudget(current_team_id, new_team_id, transfer_money);
END;
//
DELIMITER ;

#CALL TransferPlayerBetweenTeams(1, 2,100);

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
    
    -- Update the old team for the coach
    UPDATE Teams
    SET coach_id = NULL
    WHERE team_id = current_team_id;

    -- Update the team for the coach
    UPDATE Teams
    SET coach_id = coach_id_to_transfer
    WHERE team_id = new_team_id;
    
    CALL TransferBudget(current_team_id, new_team_id, transfer_money);
    

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