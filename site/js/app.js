const express = require("express");
const mysql = require("mysql2");
var cors = require("cors");
var favicon = require("serve-favicon");
const expressSanitizer = require("express-sanitizer");

const app = express();
const port = 3000;

app.use(cors());
app.use(favicon(__dirname + "./../public/favicon.ico"));
app.use(expressSanitizer());

all_pilots_sql = "CALL GetAllPilots('2022-10-28','2100-01-01', 36)";
all_upgrades_sql = "CALL GetAllUpgrades('2022-10-28','2100-01-01', 36)";
all_factions_sql = "CALL GetAllFactions('2022-10-28','2100-01-01', 36)";
pilot_matchups_sql = "CALL GetPilotMatchups(?, ?, ?, ?)";
pilot_stats_sql = "CALL GetPilotStats(?, ?, ?, ?)";
pilot_details_sql = "SELECT v_ref_pilot.pilot_name AS pilot_name,	v_ref_pilot.card_url AS pilot_card FROM v_ref_pilot WHERE v_ref_pilot.pilot_xws = ?";
upgrade_details_sql = "SELECT ref_upgrade.name AS upgrade_name,	ref_upgrade.card_url AS upgrade_card FROM ref_upgrade WHERE ref_upgrade.xws = ?";
upgrades_by_pilot_sql = "CALL GetUpgradeStatsByPilot(?, ?, ?, ?)";
pilots_by_upgrade_sql = "CALL GetPilotStatsByUpgrade(?, ?, ?, ?)";
upgrades_by_type_sql = "CALL GetAllUpgradesOfType(?,?,?,?)";
slot_by_upgrade_sql = "SELECT name FROM v_get_upgrade_slot WHERE v_get_upgrade_slot.xws = ?";

var pool = mysql.createPool({
  host: "localhost",
  user: "listfortress_ripper",
  password: "password",
  database: "atc"
});

function logRequest(req) {
  var address = req.ip;
  var today = new Date();
  var date =
    today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate();
  var time =
    today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
  var dateTime = date + " " + time;
  keys = Object.keys(req.params);
  values = Object.values(req.params);
  console.log(
    dateTime + " " + address + " " + req.path + " " + keys + " " + values
  );
}

app.get("/all_pilots", (req, res) => {
  logRequest(req);

  pool.getConnection(function(err, connection) {
    if (err) {
      console.log(err);
      // callback(true);
      return;
    }
    connection.query(all_pilots_sql, function(err, result, fields) {
      connection.release();
      if (err) throw err;
      var pilot_json = {};
      pilot_json.data = result[0];
      res.send(pilot_json);
    });
  });
});

app.get("/all_upgrades", (req, res) => {
  logRequest(req);
  pool.getConnection(function(err, connection) {
    if (err) {
      console.log(err);
      // callback(true);
      return;
    }
    connection.query(all_upgrades_sql, function(err, result, fields) {
      connection.release();
      if (err) throw err;
      var upgrade_json = {};
      upgrade_json.data = result[0];
      res.send(upgrade_json);
    });
  });
});

app.get("/all_factions", (req, res) => {
  logRequest(req);
  pool.getConnection(function(err, connection) {
    if (err) {
      console.log(err);
      // callback(true);
      return;
    }
    connection.query(all_factions_sql, function(err, result, fields) {
      connection.release();
      if (err) throw err;
      var faction_json = {};
      faction_json.data = result[0];
      res.send(faction_json);
    });
  });
});

app.get("/upgrades/:upgradeslot", (req, res) => {
  const upgrade = req.sanitize(req.params.upgradeslot);
  logRequest(req);
  pool.getConnection(function(err, connection) {
    if (err) {
      console.log(err);
      // callback(true);
      return;
    }
    connection.query(
      upgrades_by_type_sql,
      [upgrade, "2022-10-28", "2100-01-01", 36],
      function(err, result, fields) {
        connection.release();
        if (err) throw err;
        var upgrade_json = {};
        upgrade_json.data = result[0];
        res.send(upgrade_json);
      }
    );
  });
});

app.get("/upgrade_slot/:upgrade", (req, res) => {
  const upgrade = req.sanitize(req.params.upgrade);
  logRequest(req);
  pool.getConnection(function(err, connection) {
    if (err) {
      console.log(err);
      // callback(true);
      return;
    }
    connection.query(slot_by_upgrade_sql, [upgrade], function(
      err,
      result,
      fields
    ) {
      connection.release();
      if (err) throw err;
      res.send(result[0]);
    });
  });
});

app.get("/pilot/:pilotxws", (req, res) => {
  const xws = req.sanitize(req.params.pilotxws);
  logRequest(req);
  pool.getConnection(function(err, connection) {
    if (err) {
      console.log(err);
      // callback(true);
      return;
    }
    connection.query(
      pilot_matchups_sql,
      [xws, "2022-10-28", "2100-01-01", 36],
      function(err, result, fields) {
        connection.release();
        if (err) throw err;
        var pilot_json = {};
        pilot_json.data = result[0];
        res.send(pilot_json);
      }
    );
  });
});

app.get("/pilot_overview/:pilotxws", (req, res) => {
  const xws = req.sanitize(req.params.pilotxws);
  logRequest(req);
  pool.getConnection(function(err, connection) {
    if (err) {
      console.log(err);
      // callback(true);
      return;
    }
    connection.query(
      pilot_stats_sql,
      [xws, "2022-10-28", "2100-01-01", 36],
      function(err, result, fields) {
        connection.release();
        if (err) throw err;
        res.send(result[0]);
      }
    );
  });
});

app.get("/pilot_details/:pilotxws", (req, res) => {
  logRequest(req);
  pool.getConnection(function(err, connection) {
    if (err) {
      console.log(err);
      // callback(true);
      return;
    }
    const xws = req.sanitize(req.params.pilotxws);
    connection.query(pilot_details_sql, [xws], function(err, result, fields) {
      connection.release();
      if (err) throw err;
      res.send(result[0]);
    });
  });
});

app.get("/upgrade_details/:upgradexws", (req, res) => {
  logRequest(req);
  pool.getConnection(function(err, connection) {
    if (err) {
      console.log(err);
      // callback(true);
      return;
    }
    const xws = req.sanitize(req.params.upgradexws);
    connection.query(upgrade_details_sql, [xws], function(err, result, fields) {
      connection.release();
      if (err) throw err;
      res.send(result[0]);
    });
  });
});

app.get("/upgrades_pilot/:pilotxws", (req, res) => {
  const xws = req.sanitize(req.params.pilotxws);
  logRequest(req);
  pool.getConnection(function(err, connection) {
    if (err) {
      console.log(err);
      // callback(true);
      return;
    }
    connection.query(
      upgrades_by_pilot_sql,
      [xws, "2022-10-28", "2100-01-01", 36],
      function(err, result, fields) {
        connection.release();
        if (err) throw err;
        var upgrade_json = {};
        upgrade_json.data = result[0];
        res.send(upgrade_json);
      }
    );
  });
});

app.get("/pilot_upgrades/:upgradexws", (req, res) => {
  const xws = req.sanitize(req.params.upgradexws);
  logRequest(req);
  pool.getConnection(function(err, connection) {
    if (err) {
      console.log(err);
      // callback(true);
      return;
    }
    connection.query(
      pilots_by_upgrade_sql,
      [xws, "2022-10-28", "2100-01-01", 36],
      function(err, result, fields) {
        connection.release();
        if (err) throw err;
        var upgrade_json = {};
        upgrade_json.data = result[0];
        res.send(upgrade_json);
      }
    );
  });
});

app.listen(port, () => console.log(`AT.C listening on port ${port}!`));
