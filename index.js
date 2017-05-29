require("coffee-script/register");

require("./src/server")

var http = require("http");
setInterval(function() {
    http.get("http://sorteo-wimbledon.herokuapp.com");
}, 300000); // every 5 minutes (300000)
