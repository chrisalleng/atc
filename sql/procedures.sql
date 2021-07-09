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