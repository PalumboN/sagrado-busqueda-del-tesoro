config = require('./config').mongo
mongoose = require('mongoose')
mongoose.connect(config.uri)
mongoose.Promise = require('bluebird')

Schema = mongoose.Schema
Mixed = Schema.Types.Mixed

Jugador = new Schema
  nick:
    type: String
    required: true
  contraseña:
    type: String
    required: true
  edad:
    type: Number
    required: true
  token:
    type: String
    required: true


module.exports =
  Jugador: mongoose.model 'Jugador', Jugador
