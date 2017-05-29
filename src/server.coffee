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

app.post '/login', ({body}, res) ->
  query = _.pick body, ["nick", "contraseña"]
  Jugador.findOne query
  .then (jugador) ->
    if _.isEmpty jugador
      res.status(404).send "Usuario no encontrado. Verifique 'nick' y 'contraseña'."
    else
      res.send token: jugador.token

app.get '/admin/jugadores', ({query}, res) ->
  return invalidToken res unless query.token is "alcal"
  Jugador.find()
  .then (jugadores) ->
    res.send jugadores

app.all '*', (req, res) ->
  res.status(404).send "Recurso no encontrado."

invalidToken = (res) ->
  res.status(400).send "Token inválido."

app.listen port, ->
  console.log "Listen port #{port}"
