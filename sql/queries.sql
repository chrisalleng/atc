#Faction Overview Query
SELECT
	ref_faction.faction_id AS faction,
	ref_faction.icon_url AS art,
	ref_faction.xws AS faction_xws,
	main_stats.list_count AS lists,
	main_stats.avg_bid AS avg_bid,
	main_stats.avg_percentile AS avg_percentile,
	game_stats.game_count AS game_count,
	game_stats.win_count AS win_count,
	game_stats.cut_games AS cut_games,
	game_stats.cut_wins AS cut_wins
FROM (
	SELECT
		v_all_pilots.faction AS faction,
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
	WHERE v_pilots_matches.date > '2000-01-01'
		AND v_pilots_matches.date < '2100-01-01'
	GROUP BY v_pilots_matches.faction
) AS game_stats
ON main_stats.faction = game_stats.faction
JOIN ref_faction ON ref_faction.faction_id = main_stats.faction
WHERE main_stats.faction != 8