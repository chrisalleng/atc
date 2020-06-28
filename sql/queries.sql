#Pilots Overview Query
SELECT
	v_ref_pilot.pilot_name AS NAME,
	v_ref_pilot.pilot_xws AS xws,
	v_ref_pilot.art AS art,
	v_ref_pilot.card AS card,
	v_ref_pilot.faction AS faction,
	v_ref_pilot.faction_art AS faction_art,
	v_ref_pilot.faction_xws AS faction_xws,
	v_ref_pilot.ship_name AS ship_name,
	main_stats.list_count AS lists,
	main_stats.avg_bid AS avg_bid,
	main_stats.avg_percentile AS avg_percentile,
	game_stats.game_count AS game_count,
	game_stats.win_count AS win_count,
	game_stats.cut_games AS cut_games,
	game_stats.cut_wins AS cut_wins
FROM (
	SELECT
		v_all_pilots.ref_pilot_id AS ref_pilot_id,
		(200 - AVG(v_all_pilots.points)) AS avg_bid,
		COUNT(distinct(v_all_pilots.player_id)) AS list_count,
		AVG(v_all_pilots.swiss_standing) / AVG(v_all_pilots.players) AS avg_percentile,
		SUM(CASE WHEN v_all_pilots.cut_size > 0 THEN 1 ELSE 0 END) AS lists_with_cut,
		SUM(CASE WHEN v_all_pilots.cut_size > 0 AND v_all_pilots.cut_standing >0 THEN 1 ELSE 0 END) AS lists_make_cut
	FROM v_all_pilots
	WHERE v_all_pilots.date > '2000-01-01'
		AND v_all_pilots.date < '2100-01-01'
		AND v_all_pilots.players > 10
		AND v_all_pilots.fill_rate > .65
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
	WHERE v_pilots_matches.date > '2000-01-01'
		AND v_pilots_matches.date < '2100-01-01'
	GROUP BY v_pilots_matches.ref_pilot_id
) AS game_stats
ON main_stats.ref_pilot_id = game_stats.ref_pilot_id
JOIN v_ref_pilot ON v_ref_pilot.ref_pilot_id = main_stats.ref_pilot_id