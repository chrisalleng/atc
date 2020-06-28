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

#Upgrades Overview Query
SELECT
	ref_upgrade.name AS NAME,
	ref_upgrade.xws AS xws,
	ref_upgrade.art_url AS art,
	ref_upgrade.card_url AS card,
	ref_upgrade_type.name AS type_name,
	main_stats.list_count AS lists,
	main_stats.avg_bid AS avg_bid,
	main_stats.avg_percentile AS avg_percentile,
	game_stats.game_count AS game_count,
	game_stats.win_count AS win_count,
	game_stats.cut_games AS cut_games,
	game_stats.cut_wins AS cut_wins
FROM (
	SELECT
		v_all_upgrades.ref_upgrade_id AS ref_upgrade_id,
		(200 - AVG(v_all_upgrades.points)) AS avg_bid,
		COUNT(distinct(v_all_upgrades.player_id)) AS list_count,
		AVG(v_all_upgrades.swiss_standing) / AVG(v_all_upgrades.players) AS avg_percentile,
		SUM(CASE WHEN v_all_upgrades.cut_size > 0 THEN 1 ELSE 0 END) AS lists_with_cut,
		SUM(CASE WHEN v_all_upgrades.cut_size > 0 AND v_all_upgrades.cut_standing >0 THEN 1 ELSE 0 END) AS lists_make_cut
	FROM v_all_upgrades
	WHERE v_all_upgrades.date > '2000-01-01'
		AND v_all_upgrades.date < '2100-01-01'
		AND v_all_upgrades.players > 10
		AND v_all_upgrades.fill_rate > .65
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
	WHERE v_upgrades_matches.date > '2000-01-01'
		AND v_upgrades_matches.date < '2100-01-01'
	GROUP BY v_upgrades_matches.ref_upgrade_id
) AS game_stats
ON main_stats.ref_upgrade_id = game_stats.ref_upgrade_id
JOIN ref_upgrade ON ref_upgrade.ref_upgrade_id = main_stats.ref_upgrade_id
JOIN ref_upgrade_type ON ref_upgrade.upgrade_type_id = ref_upgrade_type.upgrade_type_id

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