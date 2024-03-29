import json
from datetime import datetime

import mysql.connector
import requests
import config
import os


def clean_pilot_xws(pilot_xws):
    if pilot_xws == "niennumb-t70xwing":
        pilot_xws = "niennunb"
    elif pilot_xws == "oddballarc170":
        pilot_xws = "oddball-arc170starfighter"
    elif pilot_xws == "ricolie-nabooroyaln1starfighter":
        pilot_xws = "ricolie"
    elif pilot_xws == "anakinskywalkerywing":
        pilot_xws = "anakinskywalker-btlbywing"
    elif pilot_xws == "Holo":
        pilot_xws = "holo"
    elif pilot_xws == "g4rg0rvm":
        pilot_xws = "g4rgorvm"
    elif pilot_xws == "ahsokatanoawing":
        pilot_xws = "ahsokatano-rz1awing"
    elif pilot_xws == "fennrau-rebelfangfighter":
        pilot_xws = "fennrau-rebel-fang"
    elif pilot_xws == "bokatankryze-separatist":
        pilot_xws = "bokatankryze-separatistalliance"
    elif pilot_xws == "dt798-tiefofighter":
        pilot_xws = "dt798"
    elif pilot_xws == "maulermither-battleofyavin":
        pilot_xws = "maulermithel-battleofyavin"
    elif pilot_xws == "kickback-sigeofcoruscant":
        pilot_xws = "kickback-siegeofcoruscant"
    elif pilot_xws == "axe-sigeofcoruscant":
        pilot_xws = "axe-siegeofcoruscant"
    elif pilot_xws == "hondoohnaka-firesprayclasspatrolcraft":
        pilot_xws = "hondoohnaka"

    return pilot_xws


def clean_upgrade_xws(upgrade_xws):
    if upgrade_xws == "hardpointcannon":
        upgrade_xws = "skip"
    elif upgrade_xws == "hardpointmissile":
        upgrade_xws = "skip"
    elif upgrade_xws == "hardpointtorpedo":
        upgrade_xws = "skip"
    elif upgrade_xws == "reysmilleniumfalcon":
        upgrade_xws = "reysmillenniumfalcon"
    elif upgrade_xws == "rey":
        upgrade_xws = "rey-gunner"
    elif upgrade_xws == "chewbaccaresistance":
        upgrade_xws = "chewbacca-crew-swz19"
    elif upgrade_xws == "leiaorganaresistance":
        upgrade_xws = "leiaorgana-resistance"
    elif upgrade_xws == "r2d2resistance":
        upgrade_xws = "r2d2-resistance"
    elif upgrade_xws == "slavei-separatist":
        upgrade_xws = "slavei-swz82"
    elif upgrade_xws == "fennrau-crew":
        upgrade_xws = "fennrau"
    elif upgrade_xws == "r5k6":
        upgrade_xws = "skip"
    elif upgrade_xws == "attackspeedboy":
        upgrade_xws = "skip"
    elif upgrade_xws == "r2f2":
        upgrade_xws = "skip"
    elif upgrade_xws == "sensorjammerboy":
        upgrade_xws = "skip"
    elif upgrade_xws == "unstablesublightenginesboy":
        upgrade_xws = "skip"
    elif upgrade_xws == "l337sprogrammingboy":
        upgrade_xws = "skip"
    elif upgrade_xws == "targetingastromechboy":
        upgrade_xws = "skip"
    elif upgrade_xws == "fanaticboy":
        upgrade_xws = "skip"
    elif upgrade_xws == "r2a3":
        upgrade_xws = "skip"
    elif upgrade_xws == "preciseastromechboy":
        upgrade_xws = "skip"
    elif upgrade_xws == "vengefulboy":
        upgrade_xws = "skip"
    elif upgrade_xws == "roilingangersoc":
        upgrade_xws = "roilinganger-siegeofcoruscant"
    elif upgrade_xws == "contingencyprotocolsoc":
        upgrade_xws = "contingencyprotocol-siegeofcoruscant"
    elif upgrade_xws == "evasionsequence7soc":
        upgrade_xws = "evasionsequence7-siegeofcoruscant"
    elif upgrade_xws == "ancillaryionweaponssoc":
        upgrade_xws = "ancillaryionweapons-siegeofcoruscant"
    elif upgrade_xws == "strutlockoverridesoc":
        upgrade_xws = "strutlockoverride-siegeofcoruscant"
    elif upgrade_xws == "r4p17soc":
        upgrade_xws = "r4p17-siegeofcoruscant"
    elif upgrade_xws == "preciseastromech":
        upgrade_xws = "preciseastromech-battleofyavin"
    elif upgrade_xws == "targetingastromech":
        upgrade_xws = "targetingastromech-battleofyavin"
    elif upgrade_xws == "unstablesublightengines":
        upgrade_xws = "unstablesublightengines-battleofyavin"
    elif upgrade_xws == "l337sprogramming":
        upgrade_xws = "l337sprogramming-battleofyavin"
    elif upgrade_xws == "attackspeed":
        upgrade_xws = "attackspeed-battleofyavin"
    elif upgrade_xws == "vectoredcannons":
        upgrade_xws = "vectoredcannonsrz1"
    elif upgrade_xws == "vengeful":
        upgrade_xws = "vengeful-battleofyavin"
    elif upgrade_xws == "instictiveaim":
        upgrade_xws = "instinctiveaim"

    return upgrade_xws


def clean_scenario_xws(scenario_xws):
    if scenario_xws == "Assault the Satellite Array":
        scenario_xws = "Assault at the Satellite Array"

    return scenario_xws


def clear_tables(input_cursor):
    input_cursor.execute("DROP TABLE IF EXISTS matches_players")
    input_cursor.execute("DROP TABLE IF EXISTS matches")
    input_cursor.execute("DROP TABLE IF EXISTS upgrades")
    input_cursor.execute("DROP TABLE IF EXISTS pilots")
    input_cursor.execute("DROP TABLE IF EXISTS players")
    input_cursor.execute("DROP TABLE IF EXISTS tournaments")
    input_cursor.execute("DROP TABLE IF EXISTS ref_pilot")
    input_cursor.execute("DROP TABLE IF EXISTS ref_ship")
    input_cursor.execute("DROP TABLE IF EXISTS ref_upgrade")
    input_cursor.execute("DROP TABLE IF EXISTS ref_upgrade_type")
    input_cursor.execute("DROP TABLE IF EXISTS ref_faction")

    input_cursor.execute("CREATE TABLE ref_ship ("
                         "ship_id INT AUTO_INCREMENT PRIMARY KEY,"
                         "ship_name VARCHAR(255))")

    input_cursor.execute("CREATE TABLE ref_faction ("
                         "faction_id INT AUTO_INCREMENT PRIMARY KEY,"
                         "name VARCHAR(255), "
                         "icon_url VARCHAR(255), "
                         "xws VARCHAR(255))")

    input_cursor.execute("CREATE TABLE ref_upgrade_type ("
                         "upgrade_type_id INT AUTO_INCREMENT PRIMARY KEY,"
                         "name VARCHAR(255))")

    input_cursor.execute("CREATE TABLE ref_pilot ("
                         "ref_pilot_id INT AUTO_INCREMENT PRIMARY KEY,"
                         "ship_id INT,"
                         "faction_id INT,"
                         "name VARCHAR(255), "
                         "cost INT,"
                         "initiative INT,"
                         "xws VARCHAR(255),"
                         "art_url VARCHAR(255),"
                         "card_url VARCHAR(255),"
                         "standard BIT,"
                         "subtitle VARCHAR(255),"
                         "FOREIGN KEY(faction_id) REFERENCES ref_faction(faction_id),"
                         "FOREIGN KEY(ship_id) REFERENCES ref_ship(ship_id))")

    input_cursor.execute("CREATE TABLE ref_upgrade ("
                         "ref_upgrade_id INT AUTO_INCREMENT PRIMARY KEY,"
                         "upgrade_type_id INT,"
                         "name VARCHAR(255), "
                         "art_url VARCHAR(255), "
                         "card_url VARCHAR(255), "
                         "cost INT,"
                         "xws VARCHAR(255),"
                         "FOREIGN KEY(upgrade_type_id) REFERENCES ref_upgrade_type(upgrade_type_id))")

    input_cursor.execute("CREATE TABLE tournaments ("
                         "tournament_id INT AUTO_INCREMENT PRIMARY KEY,"
                         "players INT, "
                         "date DATE,"
                         "cut_size INT,"
                         "fill_rate DOUBLE,"
                         "format INT)")

    input_cursor.execute("CREATE TABLE players ("
                         "player_id INT AUTO_INCREMENT PRIMARY KEY, "
                         "tournament_id INT,"
                         "faction INT, "
                         "points INT, "
                         "swiss_standing INT, "
                         "cut_standing INT,"
                         "FOREIGN KEY(tournament_id) REFERENCES tournaments(tournament_id),"
                         "FOREIGN KEY(faction) REFERENCES ref_faction(faction_id))")

    input_cursor.execute("CREATE TABLE pilots ("
                         "pilot_id INT AUTO_INCREMENT PRIMARY KEY, "
                         "player_id INT,"
                         "points INT,"
                         "ref_pilot_id INT,"
                         "FOREIGN KEY(player_id) REFERENCES players(player_id),"
                         "FOREIGN KEY(ref_pilot_id) REFERENCES ref_pilot(ref_pilot_id))")

    input_cursor.execute("CREATE TABLE upgrades ("
                         "upgrade_id INT AUTO_INCREMENT PRIMARY KEY, "
                         "pilot_id INT,"
                         "ref_upgrade_id INT,"
                         "FOREIGN KEY(pilot_id) REFERENCES pilots(pilot_id),"
                         "FOREIGN KEY(ref_upgrade_id) REFERENCES ref_upgrade(ref_upgrade_id))")

    input_cursor.execute("CREATE TABLE matches ("
                         "match_id INT AUTO_INCREMENT PRIMARY KEY,"
                         "winner_id INT,"
                         "type INT,"
                         "scenario VARCHAR(255),"
                         "FOREIGN KEY(winner_id) REFERENCES players(player_id))")

    input_cursor.execute("CREATE TABLE matches_players ("
                         "entry_id INT AUTO_INCREMENT PRIMARY KEY,"
                         "match_id INT,"
                         "player_id INT,"
                         "player_points INT,"
                         "FOREIGN KEY(player_id) REFERENCES players(player_id),"
                         "FOREIGN KEY(match_id) REFERENCES matches(match_id))")


def get_ref_data():
    parsed_pilots = []
    parsed_upgrades = []

    for root, dirs, files in os.walk("lib/xwing-data2/data/pilots"):
        for filename in files:
            with open(os.path.join(root, filename), "r", encoding="utf8") as raw_file:
                full_json = json.load(raw_file)
                for single_pilot in full_json['pilots']:
                    if single_pilot['standard'] is True:
                        single_pilot['ship'] = full_json['name']
                        single_pilot['faction'] = full_json['faction']
                        parsed_pilots.append(single_pilot)

    for root, dirs, files in os.walk("lib/xwing-data2/data/upgrades"):
        for filename in files:
            with open(os.path.join(root, filename), "r", encoding="utf8") as raw_file:
                full_json = json.load(raw_file)
                for single_upgrade in full_json:
                    if single_upgrade['standard'] is True:
                        parsed_upgrades.append(single_upgrade)

    ships = {}
    pilots = {}
    upgrades = {}
    pilot_id = 0
    upgrade_id = 0

    faction_sql = "INSERT INTO ref_faction (faction_id, name, xws, icon_url) VALUES (%s, %s, %s, %s)"
    factions_values = [
        (1, "Rebel Alliance", "rebelalliance", "https://infinitearenas.com/xw2/images/artwork/faction-icons/Rebel.png"),
        (2, "Galactic Empire", "galacticempire", "https://infinitearenas.com/xw2/images/artwork/faction-icons/Imperial.png"),
        (3, "Scum and Villainy", "scumandvillainy", "https://infinitearenas.com/xw2/images/artwork/faction-icons/Scum.png"),
        (4, "Resistance", "resistance", "https://infinitearenas.com/xw2/images/artwork/faction-icons/ResistanceIcon.png"),
        (5, "First Order", "firstorder", "https://infinitearenas.com/xw2/images/artwork/faction-icons/FirstOrderIcon.png"),
        (6, "Galactic Republic", "galacticrepublic",
         "https://infinitearenas.com/xw2/images/artwork/faction-icons/RepublicIcon.png"),
        (7, "Separatist Alliance", "separatistalliance",
         "https://infinitearenas.com/xw2/images/artwork/faction-icons/SeparatistIcon.png"),
        (8, "Unknown", "unknown", "unknown")]

    for parsed_pilot in parsed_pilots:
        pilot_name = parsed_pilot['name']
        pilot_xws = parsed_pilot['xws']
        pilot_cost = parsed_pilot['cost']
        pilot_standard = parsed_pilot['standard']
        pilot_id = pilot_id + 1
        if pilot_cost == "???":
            continue
        pilot_initiative = parsed_pilot['initiative']
        ship = parsed_pilot['ship']

        pilot_faction = parsed_pilot['faction']

        for faction in factions_values:
            if faction[1] == pilot_faction:
                pilot_faction = faction[0]
        if 'artwork' in parsed_pilot:
            pilot_art = parsed_pilot['artwork']
        else:
            pilot_art = ""
        if 'image' in parsed_pilot:
            pilot_card = parsed_pilot['image']
        else:
            pilot_card = ""

        if 'caption' in parsed_pilot:
            pilot_subtitle = parsed_pilot['caption']
        else:
            pilot_subtitle = "Generic"

        if ship not in ships:
            ships[ship] = (ship, len(ships) + 1)
        pilots[pilot_xws] = (
            pilot_name, pilot_xws, pilot_cost, pilot_initiative, ships[ship][1], pilot_id, pilot_faction, pilot_art,
            pilot_card, pilot_standard, pilot_subtitle)

    ref_upgrade_types = []

    for parsed_upgrade in parsed_upgrades:
        upgrade_type = parsed_upgrade['sides'][0]['type']
        if upgrade_type not in ref_upgrade_types:
            ref_upgrade_types.append(upgrade_type)
        upgrade_type_id = ref_upgrade_types.index(upgrade_type) + 1
        upgrade_name = parsed_upgrade['name']
        upgrade_xws = parsed_upgrade['xws']
        upgrade_id = upgrade_id + 1
        if 'artwork' in parsed_upgrade['sides'][0]:
            upgrade_art = parsed_upgrade['sides'][0]['artwork']
        else:
            upgrade_art = ""
        if 'image' in parsed_upgrade['sides'][0]:
            upgrade_card = parsed_upgrade['sides'][0]['image']
        else:
            upgrade_card = ""
        if 'cost' in parsed_upgrade:
            if parsed_upgrade['cost']['value'] != "?":
                upgrade_cost = parsed_upgrade['cost']['value']
            else:
                upgrade_cost = 200
        else:
            upgrade_cost = 0

        upgrades[upgrade_xws] = (
        upgrade_name, upgrade_type_id, upgrade_xws, upgrade_cost, upgrade_id, upgrade_art, upgrade_card)
    all_ref_pilots = []
    for pilot in pilots.items():
        pilot = pilot[1]
        all_ref_pilots.append(pilot)

    all_ref_ships = []
    for ship in ships.items():
        ship = ship[1]
        all_ref_ships.append(ship)
    sql = "INSERT INTO ref_ship (ship_name, ship_id) " \
          " VALUES (%s, %s) "
    cursor.executemany(sql, all_ref_ships)

    cursor.executemany(faction_sql, factions_values)

    sql = "INSERT INTO ref_pilot (name, xws, cost, initiative, ship_id, ref_pilot_id, faction_id, art_url, card_url, standard, subtitle) " \
          " VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s) "
    cursor.executemany(sql, all_ref_pilots)

    upgrade_types_with_id = []
    for upgrade_type in ref_upgrade_types:
        upgrade_types_with_id.append([ref_upgrade_types.index(upgrade_type) + 1, upgrade_type])

    sql = "INSERT INTO ref_upgrade_type (upgrade_type_id, name) VALUES (%s, %s)"
    cursor.executemany(sql, upgrade_types_with_id)

    all_ref_upgrades = []
    for upgrade in upgrades.items():
        upgrade = upgrade[1]
        all_ref_upgrades.append(upgrade)

    sql = "INSERT INTO ref_upgrade (name, upgrade_type_id, xws, cost, ref_upgrade_id, art_url, card_url) " \
          " VALUES (%s, %s, %s, %s, %s, %s, %s) "
    cursor.executemany(sql, all_ref_upgrades)

    factions = {
    }

    for faction_value in factions_values:
        factions[faction_value[2]] = faction_value[0]
    return ships, pilots, upgrades, factions


def update_tables(pilots, upgrades, factions, filename):
    with open(filename) as json_file:
        data = json.load(json_file)
        all_pilots = []
        all_upgrades = []
        all_matches = []
        all_players = []
        all_players_matches = []
        all_tournaments = []
        pilot_id = 0
        for tournament in data:
            filterdate = datetime.strptime('05-27-2022', '%m-%d-%Y')
            tournamentdate = datetime.strptime(tournament['date'], '%Y-%m-%d')
            if tournamentdate < filterdate:
                continue
            tournament_player_count = len(tournament['participants'])
            tournament_id = tournament['id']
            # Skip Worlds Dupes also random bad data
            if tournament_id == 1206 or tournament_id == 1193 or tournament_id == 3012 or tournament_id == 3022\
                    or tournament_id == 3028 or tournament_id == 3034 or tournament_id == 3039 or tournament_id == 3049 or tournament_id == 3089:
                continue
            print(tournament_id)
            players_with_lists = 0
            for player in tournament['participants']:
                if player['list_json'] is not None and player['list_json'].strip():
                    players_with_lists += 1
            # Get Tournaments
            date = tournament['date']
            tournament_format = tournament['format_id']

            # Get Players
            highest_cut_rank = 0
            for player in tournament['participants']:
                player_list = {}
                if player['top_cut_rank'] is not None:
                    if player['top_cut_rank'] > highest_cut_rank:
                        highest_cut_rank = player['top_cut_rank']
                if player['list_json'] is not None:
                    try:
                        player_list = json.loads(player['list_json'])
                    except ValueError as e:
                        pass
                if 'points' in player_list and player_list['points'] is not None and player_list['points'] != 0 \
                        and isinstance(player_list['points'], int):
                    points = player_list['points']
                else:
                    points = None
                player_id = player['id']
                if 'faction' in player_list:
                    faction = factions[player_list['faction']]
                else:
                    faction = 8
                swiss_standing = player['swiss_rank']
                if swiss_standing == 0:
                    swiss_standing = tournament_player_count
                cut_standing = player['top_cut_rank']

                values = (player_id, tournament_id, faction, points, swiss_standing, cut_standing)
                all_players.append(values)

                # Insert Pilots
                if 'pilots' in player_list:
                    for pilot in player_list['pilots']:
                        if 'id' in pilot:
                            xws = pilot['id']
                        else:
                            xws = pilot['name']
                        xws = clean_pilot_xws(xws)
                        ref_pilot_id = pilots[xws][5]
                        if 'points' in pilot and isinstance(pilot['points'], int):
                            points = pilot['points']
                        else:
                            points = None
                        pilot_id = pilot_id + 1
                        current_pilot = (player_id, ref_pilot_id, points)
                        all_pilots.append(current_pilot)

                        if 'upgrades' in pilot and len(pilot['upgrades']) > 0:
                            # Insert Upgrade
                            pilot_upgrades = pilot['upgrades'].items()
                            for key, value in pilot_upgrades:
                                upgrade_list = value
                                for upgrade in upgrade_list:
                                    upgrade = clean_upgrade_xws(upgrade)
                                    if upgrade == "skip":
                                        continue
                                    upgrade_id = upgrades[upgrade][4]
                                    current_upgrade = (pilot_id, upgrade_id)
                                    all_upgrades.append(current_upgrade)

            # Insert Tournaments
            fill_rate = 0
            if tournament_player_count > 0:
                fill_rate = players_with_lists / tournament_player_count
            all_tournaments.append((tournament_id, tournament_player_count, date, highest_cut_rank, fill_rate,
                                    tournament_format))

            # Insert all matches
            for rounds in tournament['rounds']:
                for match in rounds['matches']:
                    if match['result'] == 'bye' or match['winner_id'] is None or match['result'] == 'tie':
                        continue
                    match_id = match['id']
                    winner_id = match['winner_id']
                    match_type = rounds['roundtype_id']
                    scenario = 'Unknown'
                    if rounds['scenario']:
                        scenario = rounds['scenario']
                        scenario = clean_scenario_xws(scenario)
                    current_match = (match_id, winner_id, match_type, scenario)
                    all_matches.append(current_match)

                    player1_id = match['player1_id']
                    player1_points = match['player1_points']
                    current_player = (match_id, player1_id, player1_points)
                    all_players_matches.append(current_player)

                    player2_id = match['player2_id']
                    player2_points = match['player2_points']
                    current_player = (match_id, player2_id, player2_points)
                    all_players_matches.append(current_player)

        sql = "INSERT INTO tournaments (tournament_id, players, date, cut_size, fill_rate, format) VALUES (%s, %s, " \
              "%s, %s, %s, %s) "
        cursor.executemany(sql, all_tournaments)

        sql = "INSERT INTO players (player_id, tournament_id, faction, points,  swiss_standing, cut_standing) " \
              "VALUES (%s, %s, %s, %s, %s, %s) "
        cursor.executemany(sql, all_players)

        sql = "INSERT INTO matches (match_id, winner_id, type, scenario) VALUES (%s, %s, %s, %s) "
        cursor.executemany(sql, all_matches)

        player_sql = "INSERT INTO matches_players (match_id, player_id, player_points) VALUES (%s, %s, %s)"
        cursor.executemany(player_sql, all_players_matches)

        sql = "INSERT INTO pilots (player_id, ref_pilot_id, points) VALUES (%s, %s, %s) "
        cursor.executemany(sql, all_pilots)

        sql = "INSERT INTO upgrades (pilot_id, ref_upgrade_id) VALUES (%s, %s) "
        cursor.executemany(sql, all_upgrades)


database = mysql.connector.connect(
    host=config.hostname,
    user=config.username,
    password=config.password,
    database=config.database,
    auth_plugin='mysql_native_password'
)
cursor = database.cursor()
clear_tables(cursor)
database.commit()
ref_ships, ref_pilots, ref_upgrades, ref_factions = get_ref_data()
update_tables(ref_pilots, ref_upgrades, ref_factions, 'merged_file.json')
database.commit()
cursor.close()
database.close()
