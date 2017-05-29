module.exports =
  port: process.env.PORT || 3000
  mongo:
    uri: process.env.MONGODB_URI or 'mongodb://localhost:27017/busqueda-del-tesoro-test'
