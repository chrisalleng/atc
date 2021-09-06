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
	WHERE v_all_upgrades.date >= '2000-01-01'
		AND v_all_upgrades.date <= '2100-01-01'
		-- AND FORMAT
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
	WHERE v_upgrades_matches.date >= '2000-01-01'
		AND v_upgrades_matches.date <= '2100-01-01'
		-- AND FORMAT 
		-- AND PLAYER FILL SIZE
	GROUP BY v_upgrades_matches.ref_upgrade_id
) AS upgrades_matches
ON upgrades_matches.ref_upgrade_id = ref_upgrade.ref_upgrade_id
WHERE ref_upgrade_type.upgrade_type_id = (SELECT ref_upgrade_type.upgrade_type_id FROM ref_upgrade_type WHERE ref_upgrade_type.name = 'modification')
AND list_count > 0
ORDER BY list_count desc