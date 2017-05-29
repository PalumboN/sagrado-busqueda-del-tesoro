module.exports =
  port: process.env.PORT || 3000
  mongo:
    uri: process.env.MONGO_URI or 'mongodb://localhost:27017/busqueda-del-tesoro-test'
