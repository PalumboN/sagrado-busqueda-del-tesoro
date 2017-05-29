_ = require('lodash')
sha256 = require('sha256')
config = require('./config')
express = require('express')
{Jugador} = require('./schemas')
bodyParser = require('body-parser')

app = express()
port = config.port

app.use bodyParser.urlencoded(extended: true)

app.post '/jugadores', ({body: jugador}, res) ->
  { nick, contraseña } = jugador
  jugador.token = sha256(nick + contraseña)
  Jugador.create jugador
  .then -> res.status(201).end()
  .catch (err) -> res.status(400).send err

app.post '/login', ({body}, res) ->
  query = _.pick body, ["nick", "contraseña"]
  findJugador query
  .catch (err) ->
    res.status(404).send "Usuario no encontrado. Verifique 'nick' y 'contraseña'."
  .then (jugador) ->
    res.send token: jugador.token

app.get '/pistas', ({query: {token}}, res) ->
  findJugador {token}
  .catch (err) -> invalidToken res
  .then (jugador) ->
    res.send jugador.pistas

app.get '/pistas/:nro', ({query: {token}, params: {nro}}, res) ->
  findJugador {token}
  .catch (err) -> invalidToken res
  .then (jugador) ->
    res.send jugador.pistas[nro].texto
  .catch (err) ->
    res.status(404).send "Pista no encontrada."

app.get '/admin/jugadores', ({query: {token}}, res) ->
  return invalidToken res unless token is "alcal"
  Jugador.find()
  .then (jugadores) ->
    res.send jugadores

app.all '*', (req, res) ->
  res.status(404).send "Recurso no encontrado."

invalidToken = (res) ->
  res.status(400).send "Token inválido."


findJugador = (query) ->
  Jugador.findOne query
  .then (jugador) ->
    throw "Jugador no encontrado." if _.isEmpty jugador
    jugador

app.listen port, ->
  console.log "Listen port #{port}"
