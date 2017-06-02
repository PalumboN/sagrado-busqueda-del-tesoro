_ = require('lodash')
sha256 = require('sha256')
config = require('./config')
pistas = require('./pistas')
express = require('express')
{Jugador} = require('./schemas')
bodyParser = require('body-parser')

class RespuestaIncorrecta extends Error

soloLetras = (texto) ->
  _.replace(_.toLower(texto), " ", "")

compararStrings = (str1, str2) ->
  console.log str1, str2
  s1 = soloLetras(str1)
  s2 = soloLetras(str2)
  console.log s1
  console.log s2
  s1 == s2

esCorrecta = (respuesta, solucion) ->
  compararStrings respuesta.toString(), solucion.toString()

desbloquear = (pista, codigo) ->
  pista.bloqueada = false
  pista.codigo = codigo

app = express()
port = config.port

app.use bodyParser.urlencoded(extended: true)

app.get '/ping', (req, res) ->
  res.send("pong")

app.post '/jugadores', ({body: jugador}, res) ->
  { nick, contraseña } = jugador
  jugador.token = sha256(nick + contraseña)
  jugador.pistas = pistas.map (pista) -> _.pick pista, ["id"]
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

app.get '/pistas/:id', ({query: {token}, params: {id}}, res) ->
  findJugador {token}
  .catch (err) -> invalidToken res
  .then (jugador) ->
    res.send _.omit pistas[id-1], ["respuesta", "codigo"]
  .catch (err) ->
    res.status(404).send "Pista no encontrada."

app.post '/pistas/:id', ({body: {respuesta}, query: {token}, params: {id}}, res) ->
  findJugador {token}
  .catch (err) -> invalidToken res
  .then (jugador) ->
    pista = pistas[id-1]
    if respuesta == pista.respuesta
      desbloquear jugador.pistas[id-1], pista.codigo
      jugador.save()
      .then -> res.send "¡Pista desbloqueada!"
    else
      res.status(400).send "Respuesta incorrecta."
  .catch (err) ->
    res.status(404).send "Pista no encontrada."

app.get '/tesoro', ({query: {token}}, res) ->
  findJugador {token}
  .catch (err) -> invalidToken res
  .then (jugador) ->
    if _.every(jugador.pistas, (pista) -> not pista.bloqueada)
      res.send "Los códigos de las pistas están encriptados por cifrado Caesar con semilla = 3. Podés descifrarlos acá: http://www.brianur.info/cifrado-caesar/."
    else
      res.send "El cofre está cerrado, necesitás un código para abrirlo. ¡Resuelve todas las pistas para descubrirlo!"

app.post '/tesoro', ({body: {codigo}}, res) ->
  if codigo == "AGUANTE WEB DINAMICAS DEL ALCAL"
    res.send "¡GANASTE! https://drive.google.com/drive/folders/0B2cpfpeFNiIyb0s3QnJrc2g3NU0?usp=sharing"
  else
    res.status(400).send "Código incorrecto."

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
