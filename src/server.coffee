_ = require('lodash')
config = require('./config')
express = require('express')
{Jugador} = require('./schemas')
bodyParser = require('body-parser')

app = express()
port = config.port

app.use bodyParser.urlencoded(extended: true)

app.post '/jugadores', ({body: jugador}, res) ->
  { nick, contraseña } = jugador
  jugador.token = nick + contraseña
  Jugador.create jugador
  .then -> res.status(201).end()
  .catch (err) -> res.status(400).send err

app.get '/admin/jugadores', (req, res) ->
  return invalidToken res unless req.query.token == "alcal"
  Jugador.find()
  .then (jugadores) ->
    res.send jugadores

app.all '*', (req, res) ->
  res.status(404).send "Recurso no encontrado"

invalidToken = (res) ->
  res.status(400).send "Token inválido"

app.listen port, ->
  console.log "Listen port #{port}"
