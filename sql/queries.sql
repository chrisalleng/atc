CREATE PROCEDURE `GetPilotStatsByUpgrade`(
	IN `input_xws` VARCHAR(255),
	IN `start_date` DATE,
	IN `end_date` DATE,
	IN `input_format` INT
)
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
SELECT
	ref_pilot.name AS pilot_name,
	ref_pilot.xws AS pilot_xws,
	ref_pilot.art_url AS pilot_art,
	ref_pilot.card_url AS pilot_card,
	ref_faction.name AS faction,
	list_stats.lists,
	list_stats.avg_percentile,
	list_stats.cut_rate,
	matchup_stats.games,
	matchup_stats.wins,
	matchup_stats.winrate,
	matchup_stats.games_bigger_bid,
	matchup_stats.win_bigger_bid,
	matchup_stats.winrate_bigger_bid,
	matchup_stats.games_smaller_bid,
	matchup_stats.win_smaller_bid,
	matchup_stats.winrate_smaller_bid,
	matchup_stats.cut_count,
	matchup_stats.cut_wins,
	matchup_stats.cut_winrate
FROM
	ref_pilot
	LEFT JOIN ref_faction ON ref_pilot.faction_id = ref_faction.faction_id
	LEFT JOIN (
		SELECT
			base.pilot_xws AS pilot_xws,
			COUNT(base.xws) AS games,
			SUM(CASE WHEN winner_id = p1_player_id THEN 1 ELSE 0 END) AS wins,
			SUM(CASE WHEN winner_id = p1_player_id THEN 1 ELSE 0 END ) / COUNT(base.xws) AS winrate,
			SUM(CASE WHEN p1_points < p2_points THEN 1 ELSE 0 END) AS games_bigger_bid,
			SUM(CASE WHEN winner_id = p1_player_id AND p1_points < p2_points THEN 1 ELSE 0 END) AS win_bigger_bid,
			SUM(CASE WHEN winner_id = p1_player_id AND p1_points < p2_points THEN 1 ELSE 0 END) / 
				SUM(CASE WHEN p1_points < p2_points THEN 1 ELSE 0 END) AS winrate_bigger_bid,
			SUM(CASE WHEN p1_points > p2_points THEN 1 ELSE 0 END) AS games_smaller_bid,
			SUM(CASE WHEN winner_id = p1_player_id AND p1_points > p2_points THEN 1 ELSE 0 END) AS win_smaller_bid,
			SUM(CASE WHEN winner_id = p1_player_id AND p1_points > p2_points THEN 1 ELSE 0 END) / 
				SUM(CASE WHEN p1_points > p2_points THEN 1 ELSE 0 END) AS winrate_smaller_bid,
			SUM(CASE WHEN base.match_type = 2 THEN 1 ELSE 0 END) AS cut_count,
			SUM(CASE WHEN winner_id = p1_player_id AND base.match_type = 2 THEN 1 ELSE 0 END) AS cut_wins,
			SUM(CASE WHEN winner_id = p1_player_id AND base.match_type = 2 THEN 1 ELSE 0 END) / 
				SUM(CASE WHEN base.match_type = 2 THEN 1 ELSE 0 END) AS cut_winrate
		FROM
			(
				SELECT
					DISTINCT ref_upgrade.name AS name,
					ref_upgrade.xws AS xws,
					ref_pilot1.xws AS pilot_xws,
					m.match_id AS match_id,
					m.type AS match_type,
					p1.player_id AS p1_player_id,
					p2.player_id AS p2_player_id,
					m.winner_id AS winner_id,
					p1.points AS p1_points,
					p2.points AS p2_points,
					t.date AS date
				FROM
					matches_players player1
					JOIN matches_players player2 ON player1.match_id = player2.match_id
					JOIN matches m ON player1.match_id = m.match_id
					JOIN players p1 ON player1.player_id = p1.player_id
					JOIN players p2 ON player2.player_id = p2.player_id
					JOIN pilots pilots1 ON pilots1.player_id = player1.player_id
					JOIN ref_pilot ref_pilot1 ON ref_pilot1.ref_pilot_id = pilots1.ref_pilot_id
					JOIN tournaments t ON p1.tournament_id = t.tournament_id
					JOIN upgrades ON upgrades.pilot_id = pilots1.pilot_id
					JOIN ref_upgrade ON upgrades.ref_upgrade_id = ref_upgrade.ref_upgrade_id
				WHERE
					player1.player_id <> player2.player_id
					AND ref_upgrade.xws = input_xws
					AND t.date >= start_date
					AND t.date <= end_date
					AND t.format = input_format
					--other filters too
			) AS base
		GROUP BY
			base.pilot_xws
	) AS matchup_stats ON matchup_stats.pilot_xws = ref_pilot.xws
	LEFT JOIN (
		SELECT
			pilot_xws,
			COUNT(pilot_xws) AS lists,
			AVG(swiss_standing / players) AS avg_percentile,
			SUM(CASE WHEN cut_standing > 0 THEN 1 ELSE 0 END) / COUNT(pilot_xws) AS cut_rate
		FROM
			(
				SELECT
					distinct ref_upgrade.xws AS upgrade_xws,
					ref_pilot.xws AS pilot_xws,
					players.player_id,
					players.swiss_standing,
					tournaments.players,
					players.cut_standing
				FROM
					upgrades
					LEFT JOIN ref_upgrade ON ref_upgrade.ref_upgrade_id = upgrades.ref_upgrade_id
					LEFT JOIN pilots ON upgrades.pilot_id = pilots.pilot_id
					LEFT JOIN ref_pilot ON ref_pilot.ref_pilot_id = pilots.ref_pilot_id
					LEFT JOIN players ON pilots.player_id = players.player_id
					LEFT JOIN tournaments ON tournaments.tournament_id = players.tournament_id
				WHERE
					tournaments.date >= start_date
					AND tournaments.date <= end_date
					AND tournaments.format = input_format
					--other filters too
					AND ref_upgrade.xws = input_xws
				GROUP BY
					ref_upgrade.xws,
					ref_pilot.xws,
					players.player_id
			) AS base
		GROUP BY
			pilot_xws
	) AS list_stats ON list_stats.pilot_xws = ref_pilot.xws
WHERE
	list_stats.lists > 0
ORDER BY
	lists desc