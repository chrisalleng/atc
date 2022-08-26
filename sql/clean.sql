DROP TABLE IF EXISTS matches_players;
DROP TABLE IF EXISTS matches;
DROP TABLE IF EXISTS upgrades;
DROP TABLE IF EXISTS pilots;
DROP TABLE IF EXISTS players;
DROP TABLE IF EXISTS tournaments;
DROP TABLE IF EXISTS ref_pilot;
DROP TABLE IF EXISTS ref_ship;
DROP TABLE IF EXISTS ref_upgrade;
DROP TABLE IF EXISTS ref_upgrade_type;
DROP TABLE IF EXISTS ref_faction;

CREATE TABLE ref_ship (
ship_id INT AUTO_INCREMENT PRIMARY KEY,
ship_name VARCHAR(255));

CREATE TABLE ref_faction (
faction_id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(255), 
icon_url VARCHAR(255), 
xws VARCHAR(255));

CREATE TABLE ref_upgrade_type (
upgrade_type_id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(255));

CREATE TABLE ref_pilot (
ref_pilot_id INT AUTO_INCREMENT PRIMARY KEY,
ship_id INT,
faction_id INT,
name VARCHAR(255), 
cost INT,
initiative INT,
xws VARCHAR(255),
art_url VARCHAR(255),
card_url VARCHAR(255),
FOREIGN KEY(faction_id) REFERENCES ref_faction(faction_id),
FOREIGN KEY(ship_id) REFERENCES ref_ship(ship_id));

CREATE TABLE ref_upgrade (
ref_upgrade_id INT AUTO_INCREMENT PRIMARY KEY,
upgrade_type_id INT,
name VARCHAR(255), 
art_url VARCHAR(255), 
card_url VARCHAR(255), 
cost INT,
xws VARCHAR(255),
FOREIGN KEY(upgrade_type_id) REFERENCES ref_upgrade_type(upgrade_type_id));

CREATE TABLE tournaments (
tournament_id INT AUTO_INCREMENT PRIMARY KEY,
players INT, 
date DATE,
cut_size INT,
fill_rate DOUBLE, 
format INT);

CREATE TABLE players (
player_id INT AUTO_INCREMENT PRIMARY KEY, 
tournament_id INT,
faction INT, 
points INT, 
swiss_standing INT, 
cut_standing INT,
FOREIGN KEY(tournament_id) REFERENCES tournaments(tournament_id),
FOREIGN KEY(faction) REFERENCES ref_faction(faction_id));

CREATE TABLE pilots (
pilot_id INT AUTO_INCREMENT PRIMARY KEY, 
player_id INT,
points INT,
ref_pilot_id INT,
FOREIGN KEY(player_id) REFERENCES players(player_id),
FOREIGN KEY(ref_pilot_id) REFERENCES ref_pilot(ref_pilot_id));

CREATE TABLE upgrades (
upgrade_id INT AUTO_INCREMENT PRIMARY KEY, 
pilot_id INT,
ref_upgrade_id INT,
FOREIGN KEY(pilot_id) REFERENCES pilots(pilot_id),
FOREIGN KEY(ref_upgrade_id) REFERENCES ref_upgrade(ref_upgrade_id));

CREATE TABLE matches (
match_id INT AUTO_INCREMENT PRIMARY KEY,
winner_id INT,
type INT,
scenario VARCHAR(255),
FOREIGN KEY(winner_id) REFERENCES players(player_id));

CREATE TABLE matches_players (
entry_id INT AUTO_INCREMENT PRIMARY KEY,
match_id INT,
player_id INT,
player_points INT,
FOREIGN KEY(player_id) REFERENCES players(player_id),
FOREIGN KEY(match_id) REFERENCES matches(match_id));