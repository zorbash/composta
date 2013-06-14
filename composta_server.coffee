fs       = require 'fs'
__       = require 'underscore'
express  = require 'express'
http     = require 'http'
path     = require 'path'
optimist = require 'optimist'
moment   = require 'moment'
timeago  = require 'timeago'
Github   = require 'github'
Q        = require 'q'
util     = require 'util'

Composta = require './lib/composta'

argv = optimist
  .usage('composta the open source comparer')
  .alias('c', 'config')
  .default('c', 'config.json')
  .describe('c', 'configuration file')
  .argv

app = express()

app.set 'port', process.env.PORT || 3040
app.set 'views', __dirname + '/views'
app.set 'view engine', 'hjs'
app.use express.favicon()
app.use express.static(path.join(__dirname, 'public'))
app.use express.logger('dev')
app.use express.bodyParser()
app.use express.methodOverride()

app.listen 3040

config = JSON.parse fs.readFileSync(argv.c)
github = new Github { version: "3.0.0" }
github.authenticate config.github

Composta.github = github

app.get '/search/:q', (req, res) ->
  keywords = req.params.q.split /[ ,]+/
  if keywords.length > 1
    Composta.multiSearch(keywords).then (data) ->
      res.send data
  else 
    Composta.search(keywords[0]).then (data) ->
      res.send data
  