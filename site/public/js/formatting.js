function PercentageFormatter(value, row, index) {
  return (value * 100).toFixed(2) + "%";
}

function WinrateFormatter(value, row, index) {
  if (row.game_count === null)
    row.game_count = 0
  if (row.game_count == 0) {
    return "0%"
  }
  return (row.win_count / row.game_count* 100).toFixed(2) + "%";
}

function CutWinrateFormatter(value, row, index) {
  if (row.game_count === null)
    row.game_count = 0
  if (row.cut_games == 0) {
    return "0%"
  }
  return (row.cut_wins / row.cut_games* 100).toFixed(2) + "%";
}

function SwissRankFormatter(value, row, index) {
  return (value * 100).toFixed(2);
}

function DecimalFormatter(value, row, index) {
  return value.toFixed(2);
}

function NameLinkFormatter(value, row, index) {
    name_link = "<a class='text-white' href='" +
    "./pilot.html?pilot=" + row.pilot_xws + "'>" +
    row.pilot_name + "</a>";
    subtitle = "<a " + row.pilot_subtitle + "/a>";
  return (
    name_link + subtitle
  );
}

function UpgradesNameLinkFormatter(value, row, index) {
  return (
    "<a class='text-white' href='" +
    "./upgrade.html?upgrade=" +
    row.upgrade_xws +
    "'>" +
    row.upgrade_name +
    "</a>"
  );
}

function UpgradeNameLinkFormatter(value, row, index) {
  return (
    "<a class='text-white' href='" +
    "./pilot.html?pilot=" +
    row.pilot_xws +
    "'>" +
    row.pilot_name +
    "</a>"
  );
}

function PilotNameLinkFormatter(value, row, index) {
  return (
    "<a class='text-white' href='" +
    "./upgrade.html?upgrade=" +
    row.upgrade_xws +
    "'>" +
    row.upgrade_name +
    "</a>"
  );
}

function MatchupLinkFormatter(value, row, index) {
  return (
    "<a class='text-white' href='" +
    "./pilot.html?pilot=" +
    row.pilot2_xws +
    "'>" +
    row.pilot2_name +
    "</a>"
  );
}

function ImageMouseOverFormatter(value, row, index) {
  return (
    // "<div id='tooltip1'><a>" +
    "<img src=" + value + " height=50 />"
    // +
    // " <span><img src=" +
    // row.card +
    // " height=500  /></span></a></div>"
  );
}

function ImageMouseOverFormatterMatchups(value, row, index) {
  return (
    // "<div id='tooltip1'><a>" +
    "<img src=" + value + " height=50 />"
    // +
    // "<span><img src=" +
    // row.pilot2_card +
    // " height=500  /></span></a></div>"
  );
}

function ImageMouseOverFormatterPilotUpgrades(value, row, index) {
  return (
    // "<div id='tooltip1'><a>" +
    "<img src=" + value + " height=50 />"
    // "<span> <img src=" +
    // row.upgrade_card +
    // " height=500  /></span></a></div>"
  );
}

function getUrlParam(parameter, defaultvalue) {
  var urlparameter = defaultvalue;
  if (window.location.href.indexOf(parameter) > -1) {
    urlparameter = getUrlVars()[parameter];
  }
  return urlparameter;
}

function getUrlVars() {
  var vars = {};
  var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(
    m,
    key,
    value
  ) {
    vars[key] = value;
  });
  return vars;
}

function loadJSON(url, callback) {
  var xobj = new XMLHttpRequest();
  xobj.overrideMimeType("application/json");
  xobj.open("GET", url, false);
  xobj.onreadystatechange = function() {
    if (xobj.readyState == 4 && xobj.status == "200") {
      // Required use of an anonymous callback as .open will NOT return a value but simply returns undefined in asynchronous mode
      callback(xobj.responseText);
    }
  };
  xobj.send(null);
}
