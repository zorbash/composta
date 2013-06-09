fs       = require 'fs'
__       = require 'underscore'
express  = require 'express'
http     = require 'http'
path     = require 'path'
optimist = require 'optimist'
moment   = require 'moment'
timeago  = require 'timeago'
Github   = require 'github'

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


app.get '/search/:q', (req, res) ->
  console.log req.params.q
  github.search.repos { keyword: req.params.q }, (err, response) ->
    if response.repositories?
      repos = response.repositories[0...10]
      for k,v of repos
        parsed_date = moment(v.created_at[0...10], 'YYYY-MM-DD')
        v.created_ago = parsed_date.fromNow()
          .replace('ago', '')
          .trim()

        v.created_at = parsed_date.format 'DD-MM-YYYY'
      res.send repos
