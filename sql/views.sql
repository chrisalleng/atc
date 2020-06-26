CREATE OR REPLACE VIEW v_all_pilots as SELECT 
	pilots.ref_pilot_id, 
	players.player_id, 
	players.points, 
	players.swiss_standing, 
	players.cut_standing,
	tournaments.tournament_id, 
	tournaments.format,
	tournaments.date,
	tournaments.players, 
	tournaments.cut_size,
	tournaments.fill_rate
FROM pilots
JOIN players on players.player_id = pilots.player_id
JOIN tournaments on tournaments.tournament_id = players.tournament_id 

CREATE OR REPLACE VIEW v_pilots_matches AS
SELECT 
	pilots.pilot_id AS pilot_id,
	pilots.ref_pilot_id AS ref_pilot_id,
	pilots.player_id AS player_id,
	pilots.points AS pilot_points,
	players.faction AS faction,
	players.points AS list_points,
	players.swiss_standing AS swiss_standing,
	players.cut_standing AS cut_standing,
	matches.match_id AS match_id,
	matches.winner_id AS winner_id,
	matches.type AS match_type,
	tournaments.tournament_id AS tournament_id,
	tournaments.players AS players,
	tournaments.cut_size AS cut_size,
	tournaments.fill_rate AS fill_rate,
	tournaments.format AS FORMAT,
	tournaments.date AS date
FROM pilots
JOIN players ON players.player_id = pilots.player_id
JOIN matches_players ON matches_players.player_id = pilots.player_id
JOIN matches ON matches.match_id = matches_players.match_id
JOIN tournaments ON players.tournament_id = tournaments.tournament_id