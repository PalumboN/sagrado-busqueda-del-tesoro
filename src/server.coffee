_ = require('lodash')
express = require('express')
config = require('./config')
{Jugador} = require('./schemas')
app = express()

port = config.port

app.get '/jugadores', (req, res) ->
  Jugador.find()
  .then (jugadores) ->
    res.send jugadores

app.listen port, ->
  console.log "Listen port #{port}"
