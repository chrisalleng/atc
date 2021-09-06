DROP PROCEDURE IF EXISTS atc.GetAllPilots;
CREATE PROCEDURE `GetAllPilots`(IN `start_date` DATE, IN `end_date` DATE, IN `input_format` INT)
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
SELECT
	v_ref_pilot.pilot_name AS pilot_name,
	v_ref_pilot.pilot_xws AS pilot_xws,
	v_ref_pilot.art_url AS art_url,
	v_ref_pilot.card_url AS card_url,
	v_ref_pilot.faction_name AS faction,
	v_ref_pilot.faction_art AS faction_art,
    v_ref_pilot.faction_name AS faction_name,
	v_ref_pilot.faction_xws AS faction_xws,
	v_ref_pilot.ship_name AS ship_name,
	main_stats.list_count AS list_count,
	main_stats.avg_bid AS avg_bid,
	1 - main_stats.avg_percentile AS avg_percentile,
	game_stats.game_count AS game_count,
	game_stats.win_count AS win_count,
	game_stats.cut_games AS cut_games,
	game_stats.cut_wins AS cut_wins,
    0.0 + main_stats.lists_make_cut / main_stats.lists_with_cut AS cut_rate
FROM (
	SELECT
		v_all_pilots.ref_pilot_id AS ref_pilot_id,
		(200 - AVG(v_all_pilots.points)) AS avg_bid,
		COUNT(distinct(v_all_pilots.player_id)) AS list_count,
		AVG(v_all_pilots.swiss_standing) / AVG(v_all_pilots.players) AS avg_percentile,
		SUM(CASE WHEN v_all_pilots.cut_size > 0 THEN 1 ELSE 0 END) AS lists_with_cut,
		SUM(CASE WHEN v_all_pilots.cut_size > 0 AND v_all_pilots.cut_standing >0 THEN 1 ELSE 0 END) AS lists_make_cut
	FROM v_all_pilots
	WHERE v_all_pilots.date > start_date
		AND v_all_pilots.date < end_date
		AND v_all_pilots.players > 10
		AND v_all_pilots.fill_rate > .65
        AND v_all_pilots.format = input_format
	GROUP BY v_all_pilots.ref_pilot_id
) AS main_stats
JOIN (
	SELECT
		v_pilots_matches.ref_pilot_id AS ref_pilot_id,
		COUNT(distinct(v_pilots_matches.match_id)) AS game_count,
		COUNT(distinct CASE WHEN v_pilots_matches.player_id = v_pilots_matches.winner_id THEN v_pilots_matches.match_id ELSE 0 END) - 1 AS win_count,
		COUNT(distinct CASE WHEN v_pilots_matches.match_type = 2 THEN v_pilots_matches.match_id ELSE 0 END) -1 AS cut_games,
		COUNT(distinct CASE WHEN v_pilots_matches.match_type = 2 AND v_pilots_matches.player_id = v_pilots_matches.winner_id THEN v_pilots_matches.match_id ELSE 0 END) -1 AS cut_wins
	FROM v_pilots_matches
	WHERE v_pilots_matches.date > start_date
		AND v_pilots_matches.date < end_date
        AND v_pilots_matches.format = input_format
	GROUP BY v_pilots_matches.ref_pilot_id
) AS game_stats
ON main_stats.ref_pilot_id = game_stats.ref_pilot_id
JOIN v_ref_pilot ON v_ref_pilot.ref_pilot_id = main_stats.ref_pilot_id;

DROP PROCEDURE IF EXISTS atc.GetAllUpgrades;
CREATE PROCEDURE `GetAllUpgrades`(IN `start_date` DATE, IN `end_date` DATE, IN `input_format` INT)
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
SELECT
	ref_upgrade.name AS upgrade_name,
	ref_upgrade.xws AS upgrade_xws,
	ref_upgrade.name AS type_name,
	ref_upgrade.art_url AS art_url,
	ref_upgrade.card_url AS card_url,
	main_stats.list_count AS list_count,
	main_stats.avg_bid AS avg_bid,
	1 - main_stats.avg_percentile AS avg_percentile,
	game_stats.game_count AS game_count,
	game_stats.win_count AS win_count,
	game_stats.cut_games AS cut_games,
	game_stats.cut_wins AS cut_wins,
	0.0 + main_stats.lists_make_cut / main_stats.lists_with_cut AS cut_rate
FROM (
	SELECT
		v_all_upgrades.ref_upgrade_id AS ref_upgrade_id,
		(200 - AVG(v_all_upgrades.points)) AS avg_bid,
		COUNT(distinct(v_all_upgrades.player_id)) AS list_count,
		AVG(v_all_upgrades.swiss_standing) / AVG(v_all_upgrades.players) AS avg_percentile,
		SUM(CASE WHEN v_all_upgrades.cut_size > 0 THEN 1 ELSE 0 END) AS lists_with_cut,
		SUM(CASE WHEN v_all_upgrades.cut_size > 0 AND v_all_upgrades.cut_standing >0 THEN 1 ELSE 0 END) AS lists_make_cut
	FROM v_all_upgrades
	WHERE v_all_upgrades.date > start_date
		AND v_all_upgrades.date < end_date
		AND v_all_upgrades.players > 10
		AND v_all_upgrades.fill_rate > .65
        AND v_all_upgrades.format = input_format
	GROUP BY v_all_upgrades.ref_upgrade_id
) AS main_stats
JOIN (
	SELECT
		v_upgrades_matches.ref_upgrade_id AS ref_upgrade_id,
		COUNT(distinct(v_upgrades_matches.match_id)) AS game_count,
		COUNT(distinct CASE WHEN v_upgrades_matches.player_id = v_upgrades_matches.winner_id THEN v_upgrades_matches.match_id ELSE 0 END) - 1 AS win_count,
		COUNT(distinct CASE WHEN v_upgrades_matches.match_type = 2 THEN v_upgrades_matches.match_id ELSE 0 END) -1 AS cut_games,
		COUNT(distinct CASE WHEN v_upgrades_matches.match_type = 2 AND v_upgrades_matches.player_id = v_upgrades_matches.winner_id THEN v_upgrades_matches.match_id ELSE 0 END) -1 AS cut_wins
	FROM v_upgrades_matches
	WHERE v_upgrades_matches.date > start_date
		AND v_upgrades_matches.date < end_date
        AND v_upgrades_matches.format = input_format
	GROUP BY v_upgrades_matches.ref_upgrade_id
) AS game_stats
ON main_stats.ref_upgrade_id = game_stats.ref_upgrade_id
JOIN ref_upgrade ON ref_upgrade.ref_upgrade_id = main_stats.ref_upgrade_id;

DROP PROCEDURE IF EXISTS atc.GetAllFactions;
CREATE PROCEDURE `GetAllFactions`(IN `start_date` DATE, IN `end_date` DATE, IN `input_format` INT)
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
SELECT
	ref_faction.name AS name,
	ref_faction.icon_url AS art_url,
	ref_faction.xws AS faction_xws,
	main_stats.list_count AS lists,
	main_stats.avg_bid AS avg_bid,
	1 - main_stats.avg_percentile AS avg_percentile,
	game_stats.game_count AS game_count,
	game_stats.win_count AS win_count,
	game_stats.cut_games AS cut_games,
	game_stats.cut_wins AS cut_wins
	0.0 + main_stats.lists_make_cut / main_stats.lists_with_cut AS cut_rate
FROM (
	SELECT
		v_all_pilots.faction AS faction,
		(200 - AVG(v_all_pilots.points)) AS avg_bid,
		COUNT(distinct(v_all_pilots.player_id)) AS list_count,
		AVG(v_all_pilots.swiss_standing) / AVG(v_all_pilots.players) AS avg_percentile,
		SUM(CASE WHEN v_all_pilots.cut_size > 0 THEN 1 ELSE 0 END) AS lists_with_cut,
		SUM(CASE WHEN v_all_pilots.cut_size > 0 AND v_all_pilots.cut_standing >0 THEN 1 ELSE 0 END) AS lists_make_cut
	FROM v_all_pilots
	WHERE v_all_pilots.date > start_date
		AND v_all_pilots.date < end_date
		AND v_all_pilots.players > 10
		AND v_all_pilots.fill_rate > .65
		AND v_all_pilots.format = input_format
	GROUP BY v_all_pilots.faction
) AS main_stats
JOIN (
	SELECT
		v_pilots_matches.faction AS faction,
		COUNT(distinct(v_pilots_matches.match_id)) AS game_count,
		COUNT(distinct CASE WHEN v_pilots_matches.player_id = v_pilots_matches.winner_id THEN v_pilots_matches.match_id ELSE 0 END) - 1 AS win_count,
		COUNT(distinct CASE WHEN v_pilots_matches.match_type = 2 THEN v_pilots_matches.match_id ELSE 0 END) -1 AS cut_games,
		COUNT(distinct CASE WHEN v_pilots_matches.match_type = 2 AND v_pilots_matches.player_id = v_pilots_matches.winner_id THEN v_pilots_matches.match_id ELSE 0 END) -1 AS cut_wins
	FROM v_pilots_matches
	WHERE v_pilots_matches.date > start_date
		AND v_pilots_matches.date < end_date
		AND v_pilots_matches.format = input_format
	GROUP BY v_pilots_matches.faction
) AS game_stats
ON main_stats.faction = game_stats.faction
JOIN ref_faction ON ref_faction.faction_id = main_stats.faction
WHERE main_stats.faction != 8

DROP PROCEDURE IF EXISTS atc.GetUpgradeStatsByPilot;
CREATE PROCEDURE `GetUpgradeStatsByPilot`(
	IN `input_xws` VARCHAR(255),
	IN `start_date` DATE,
	IN `end_date` DATE,
	IN `input_format` INT)
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
SELECT 
	ref_upgrade.name AS upgrade_name,
	ref_upgrade.xws AS upgrade_xws,
	ref_upgrade_type.name AS upgrade_type,
	ref_upgrade.art_url AS upgrade_art,
	ref_upgrade.card_url AS upgrade_card,
	list_stats.lists,
	1 - list_stats.avg_percentile AS avg_percentile,
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
	matchup_stats.games_cut,
	matchup_stats.wins_cut,
	matchup_stats.winrate_cut
FROM ref_upgrade
LEFT JOIN ref_upgrade_type ON ref_upgrade.upgrade_type_id = ref_upgrade_type.upgrade_type_id
LEFT JOIN (
	SELECT 
		base.xws AS upgrade_xws,
		COUNT(base.xws) AS games,
		SUM(CASE WHEN winner_id = p1_player_id THEN 1 ELSE 0 END) AS wins,
		SUM(CASE WHEN winner_id = p1_player_id THEN 1 ELSE 0 END) / COUNT(base.xws) AS winrate,
		SUM(CASE WHEN p1_points < p2_points THEN 1 ELSE 0 END) AS games_bigger_bid,
		SUM(CASE WHEN winner_id = p1_player_id AND p1_points < p2_points THEN 1 ELSE 0 END) AS win_bigger_bid,
		SUM(CASE WHEN winner_id = p1_player_id AND p1_points < p2_points THEN 1 ELSE 0 END) / SUM(CASE WHEN p1_points < p2_points THEN 1 ELSE 0 END) AS winrate_bigger_bid,
		SUM(CASE WHEN p1_points > p2_points THEN 1 ELSE 0 END) AS games_smaller_bid,
		SUM(CASE WHEN winner_id = p1_player_id AND p1_points > p2_points THEN 1 ELSE 0 END) AS win_smaller_bid,
		SUM(CASE WHEN winner_id = p1_player_id AND p1_points > p2_points THEN 1 ELSE 0 END) / SUM(CASE WHEN p1_points > p2_points THEN 1 ELSE 0 END) AS winrate_smaller_bid,
		SUM(CASE WHEN base.match_type =2 THEN 1 ELSE 0 END) AS games_cut,
		SUM(CASE WHEN winner_id = p1_player_id AND base.match_type =2 THEN 1 ELSE 0 END) AS wins_cut,
		SUM(CASE WHEN winner_id = p1_player_id AND base.match_type =2 THEN 1 ELSE 0 END) / SUM(CASE WHEN base.match_type =2 THEN 1 ELSE 0 END) AS winrate_cut
	FROM (
	SELECT 
		ref_upgrade.name AS NAME,
		ref_upgrade.xws AS xws,
		m.match_id AS match_id,
		p1.player_id AS p1_player_id, 
		p2.player_id AS p2_player_id, 
		m.winner_id AS winner_id, 
		m.type AS match_type,
		p1.points AS p1_points, 
		p2.points AS p2_points, 
		t.date AS date
	FROM matches_players player1
	JOIN matches_players player2 ON player1.match_id = player2.match_id
	JOIN matches m ON player1.match_id = m.match_id
	JOIN players p1 ON player1.player_id = p1.player_id
	JOIN players p2 ON player2.player_id = p2.player_id
	JOIN pilots pilots1 ON pilots1.player_id = player1.player_id
	JOIN ref_pilot ref_pilot1 ON ref_pilot1.ref_pilot_id = pilots1.ref_pilot_id
	JOIN tournaments t ON p1.tournament_id = t.tournament_id
	JOIN upgrades ON upgrades.pilot_id = pilots1.pilot_id
	JOIN ref_upgrade ON upgrades.ref_upgrade_id = ref_upgrade.ref_upgrade_id
	WHERE player1.player_id <> player2.player_id
	AND ref_pilot1.xws = input_xws
	AND t.date >= start_date
	AND t.date <= end_date
	AND t.format = input_format
	) AS base
	GROUP BY base.xws) 
AS matchup_stats ON matchup_stats.upgrade_xws = ref_upgrade.xws
LEFT JOIN (
	SELECT
	xws,
	COUNT(xws) AS lists,
	AVG(swiss_standing / players) AS avg_percentile,
	SUM(CASE WHEN cut_standing > 0 THEN 1 ELSE 0 END) / COUNT(xws) AS cut_rate
FROM (
		SELECT
			ref_upgrade.xws,
			players.player_id,
			players.swiss_standing,
			tournaments.players,
			players.cut_standing
		FROM upgrades
		LEFT JOIN ref_upgrade ON ref_upgrade.ref_upgrade_id = upgrades.ref_upgrade_id
		LEFT JOIN pilots ON upgrades.pilot_id = pilots.pilot_id 
		LEFT JOIN ref_pilot ON ref_pilot.ref_pilot_id = pilots.ref_pilot_id
		LEFT JOIN players ON pilots.player_id = players.player_id
		LEFT JOIN tournaments ON tournaments.tournament_id = players.tournament_id
		WHERE tournaments.date >= start_date
		AND tournaments.date <= end_date
		AND tournaments.format = input_format
		AND ref_pilot.xws = input_xws
		GROUP BY ref_upgrade.xws, players.player_id
	)
	AS base
	GROUP BY xws
) AS list_stats ON list_stats.xws = ref_upgrade.xws
WHERE list_stats.lists > 0
ORDER BY lists desc

DROP PROCEDURE IF EXISTS atc.GetPilotStats;
CREATE PROCEDURE `GetPilotStats`(
	IN `xws` VARCHAR(255),
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
	pilot1_xws AS pilot1_xws,
	pilot2_initiative AS pilot2_initiative,
	COUNT(pilot1_xws) AS games,
	SUM(CASE WHEN winner_id = p1_player_id THEN 1 ELSE 0 END) AS wins,
	SUM(CASE WHEN winner_id = p1_player_id THEN 1 ELSE 0 END) / COUNT(pilot1_xws) AS winrate,
	SUM(CASE WHEN p1_points < p2_points THEN 1 ELSE 0 END) AS games_bigger_bid,
	SUM(CASE WHEN winner_id = p1_player_id AND p1_points < p2_points THEN 1 ELSE 0 END) AS win_bigger_bid,
	SUM(CASE WHEN winner_id = p1_player_id AND p1_points < p2_points THEN 1 ELSE 0 END) / SUM(CASE WHEN p1_points < p2_points THEN 1 ELSE 0 END) AS winrate_bigger_bid,
	SUM(CASE WHEN p1_points > p2_points THEN 1 ELSE 0 END) AS games_smaller_bid,
	SUM(CASE WHEN winner_id = p1_player_id AND p1_points > p2_points THEN 1 ELSE 0 END) AS win_smaller_bid,
	SUM(CASE WHEN winner_id = p1_player_id AND p1_points > p2_points THEN 1 ELSE 0 END) / SUM(CASE WHEN p1_points > p2_points THEN 1 ELSE 0 END) AS winrate_smaller_bid
FROM (
SELECT 
	DISTINCT ref_pilot1.xws AS pilot1_xws, 
				ref_pilot2.initiative AS pilot2_initiative,
				p1.player_id AS p1_player_id, 
				p2.player_id AS p2_player_id, 
				m.winner_id AS winner_id, 
				m.match_id AS match_id,
				p1.points AS p1_points, 
				p2.points AS p2_points, 
				t.date AS date
FROM matches_players player1
JOIN matches_players player2 ON player1.match_id = player2.match_id
JOIN matches m ON player1.match_id = m.match_id
JOIN players p1 ON player1.player_id = p1.player_id
JOIN players p2 ON player2.player_id = p2.player_id
JOIN pilots pilots1 ON pilots1.player_id = player1.player_id
JOIN pilots pilots2 ON pilots2.player_id = player2.player_id
JOIN ref_pilot ref_pilot1 ON ref_pilot1.ref_pilot_id = pilots1.ref_pilot_id
JOIN ref_pilot ref_pilot2 ON ref_pilot2.ref_pilot_id = pilots2.ref_pilot_id
JOIN ref_faction ON ref_pilot2.faction_id = ref_faction.faction_id
JOIN ref_ship ON ref_pilot2.ship_id = ref_ship.ship_id
JOIN tournaments t ON p1.tournament_id = t.tournament_id
WHERE player1.player_id <> player2.player_id
AND ref_pilot1.xws = xws
AND t.date >= start_date
AND t.date <= end_date
AND t.format = input_format
) AS base
GROUP BY pilot1_xws, pilot2_initiative
ORDER BY pilot2_initiative asc

DROP PROCEDURE IF EXISTS atc.GetPilotMatchups;
CREATE PROCEDURE `GetPilotMatchups`(
	IN `xws` VARCHAR(255),
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
	pilot1_xws AS pilot1_xws,
	pilot2_xws AS pilot2_xws,
	pilot2_name AS pilot2_name,
	pilot2_art AS pilot2_art,
	pilot2_card AS pilot2_card,
	pilot2_faction_icon AS pilot2_faction_icon,
	pilot2_faction_name AS pilot2_faction_name,
	pilot2_ship_name AS pilot2_ship_name,
	COUNT(pilot1_xws) AS games,
	SUM(CASE WHEN winner_id = p1_player_id THEN 1 ELSE 0 END) AS wins,
	SUM(CASE WHEN winner_id = p1_player_id THEN 1 ELSE 0 END) / COUNT(pilot1_xws) AS winrate,
	SUM(CASE WHEN p1_points < p2_points THEN 1 ELSE 0 END) AS games_bigger_bid,
	SUM(CASE WHEN winner_id = p1_player_id AND p1_points < p2_points THEN 1 ELSE 0 END) AS win_bigger_bid,
	SUM(CASE WHEN winner_id = p1_player_id AND p1_points < p2_points THEN 1 ELSE 0 END) / SUM(CASE WHEN p1_points < p2_points THEN 1 ELSE 0 END) AS winrate_bigger_bid,
	SUM(CASE WHEN p1_points > p2_points THEN 1 ELSE 0 END) AS games_smaller_bid,
	SUM(CASE WHEN winner_id = p1_player_id AND p1_points > p2_points THEN 1 ELSE 0 END) AS win_smaller_bid,
	SUM(CASE WHEN winner_id = p1_player_id AND p1_points > p2_points THEN 1 ELSE 0 END) / SUM(CASE WHEN p1_points > p2_points THEN 1 ELSE 0 END) AS winrate_smaller_bid,
	SUM(CASE WHEN base.match_type =2 THEN 1 ELSE 0 END) AS games_cut,
	SUM(CASE WHEN winner_id = p1_player_id AND base.match_type =2 THEN 1 ELSE 0 END) AS wins_cut,
	SUM(CASE WHEN winner_id = p1_player_id AND base.match_type =2 THEN 1 ELSE 0 END) / SUM(CASE WHEN base.match_type =2 THEN 1 ELSE 0 END) AS winrate_cut
FROM (
SELECT 
	DISTINCT ref_pilot1.xws AS pilot1_xws, 
				ref_pilot2.xws AS pilot2_xws,
				ref_pilot2.name AS pilot2_name,
				ref_pilot2.art_url AS pilot2_art,
				ref_pilot2.card_url AS pilot2_card,
				ref_faction.icon_url AS pilot2_faction_icon,
				ref_faction.name AS pilot2_faction_name,
				ref_ship.ship_name AS pilot2_ship_name,
				p1.player_id AS p1_player_id, 
				p2.player_id AS p2_player_id, 
				m.winner_id AS winner_id, 
				m.match_id AS match_id,
				m.type AS match_type,
				p1.points AS p1_points, 
				p2.points AS p2_points, 
				t.date AS date
FROM matches_players player1
JOIN matches_players player2 ON player1.match_id = player2.match_id
JOIN matches m ON player1.match_id = m.match_id
JOIN players p1 ON player1.player_id = p1.player_id
JOIN players p2 ON player2.player_id = p2.player_id
JOIN pilots pilots1 ON pilots1.player_id = player1.player_id
JOIN pilots pilots2 ON pilots2.player_id = player2.player_id
JOIN ref_pilot ref_pilot1 ON ref_pilot1.ref_pilot_id = pilots1.ref_pilot_id
JOIN ref_pilot ref_pilot2 ON ref_pilot2.ref_pilot_id = pilots2.ref_pilot_id
JOIN ref_faction ON ref_pilot2.faction_id = ref_faction.faction_id
JOIN ref_ship ON ref_pilot2.ship_id = ref_ship.ship_id
JOIN tournaments t ON p1.tournament_id = t.tournament_id
WHERE player1.player_id <> player2.player_id
AND ref_pilot1.xws = xws
AND t.date >= start_date
AND t.date <= end_date
AND t.format = input_format
) AS base
GROUP BY pilot1_xws, pilot2_xws, pilot2_art, pilot2_card, pilot2_faction_icon, pilot2_faction_name, pilot2_ship_name, pilot2_name
ORDER BY games desc

DROP PROCEDURE IF EXISTS atc.GetAllUpgradesOfType;
CREATE PROCEDURE `GetAllUpgradesOfType`(
	IN `input_type` VARCHAR(255),
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
	ref_upgrade.name AS name,
	ref_upgrade.xws AS xws,
	ref_upgrade_type.name AS type_name,
	upgrade_stats.avg_bid AS avg_bid,
	upgrade_stats.list_count AS list_count,
	upgrade_stats.list_cut_count AS list_cut_count,
	upgrade_stats.swiss_result / upgrade_stats.swiss_count AS avg_percentile,
	upgrades_matches.game_count AS game_count,
	upgrades_matches.win_count AS win_count,
	upgrades_matches.cut_games AS cut_count,
	upgrades_matches.cut_wins AS cut_win_count,
	ref_upgrade.art_url AS art,
	ref_upgrade.card_url AS card,
	0.0 + upgrade_stats.list_cut_count / upgrade_stats.list_count AS cut_rate,
	upgrades_matches.win_count / upgrades_matches.game_count AS win_rate,
	upgrades_matches.cut_wins / upgrades_matches.cut_games AS cut_winrate
FROM
	ref_upgrade
LEFT JOIN ref_upgrade_type ON ref_upgrade.upgrade_type_id = ref_upgrade_type.upgrade_type_id
LEFT JOIN
(
	SELECT
		v_all_upgrades.ref_upgrade_id AS ref_upgrade_id,
		COUNT(DISTINCT(v_all_upgrades.player_id)) AS list_count,
		(200 - AVG(v_all_upgrades.points)) AS avg_bid,
		AVG(v_all_upgrades.players) AS swiss_count,
		AVG(v_all_upgrades.swiss_standing) AS swiss_result,
		SUM(CASE WHEN v_all_upgrades.cut_size > 0 AND v_all_upgrades.cut_standing > 0 THEN 1 ELSE 0 END) AS list_cut_count
	FROM v_all_upgrades
	WHERE v_all_upgrades.date >= start_date
		AND v_all_upgrades.date <= end_date
		AND v_all_upgrades.format = input_format
		-- AND FILL SIZE
	GROUP BY v_all_upgrades.ref_upgrade_id
) AS upgrade_stats
ON upgrade_stats.ref_upgrade_id = ref_upgrade.ref_upgrade_id
LEFT JOIN 
(
	SELECT
		v_upgrades_matches.ref_upgrade_id AS ref_upgrade_id,
		COUNT(DISTINCT(v_upgrades_matches.match_id)) AS game_count,
		COUNT(distinct CASE WHEN v_upgrades_matches.player_id = v_upgrades_matches.winner_id THEN v_upgrades_matches.match_id ELSE 0 END) - 1 AS win_count,
		COUNT(distinct CASE WHEN v_upgrades_matches.match_type = 2 THEN v_upgrades_matches.match_id ELSE 0 END) -1 AS cut_games,
		COUNT(distinct CASE WHEN v_upgrades_matches.match_type = 2 AND v_upgrades_matches.player_id = v_upgrades_matches.winner_id THEN v_upgrades_matches.match_id ELSE 0 END) -1 AS cut_wins
	FROM v_upgrades_matches
	WHERE v_upgrades_matches.date >= start_date
		AND v_upgrades_matches.date <= end_date
		AND v_upgrades_matches.format = input_format
		-- AND PLAYER FILL SIZE
	GROUP BY v_upgrades_matches.ref_upgrade_id
) AS upgrades_matches
ON upgrades_matches.ref_upgrade_id = ref_upgrade.ref_upgrade_id
WHERE ref_upgrade_type.upgrade_type_id = (SELECT ref_upgrade_type.upgrade_type_id FROM ref_upgrade_type WHERE ref_upgrade_type.name = 'modification')
AND list_count > 0
ORDER BY list_count desc