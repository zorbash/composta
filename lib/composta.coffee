moment = require 'moment'
Q      = require 'q'
__     = require 'underscore'


Composta = class Composta
  @search: (query) ->
    dfd = Q.defer()
    @github.search.repos { keyword: query }, (err, response) ->
      if response.repositories?
        repos = response.repositories[0...10]
        for k,v of repos
          parsed_date = moment(v.created_at[0...10], 'YYYY-MM-DD')

          v.created_ago = parsed_date.fromNow()
            .replace('ago', '')
            .trim()
          v.color = "hsl(#{__.random(0,360)}, 50%, 50%)"
          v.created_at = parsed_date.format 'DD-MM-YYYY'
          v.age_seconds = ~~(parseInt(parsed_date.format('X'), 10) / (3600 * 24))
        dfd.resolve repos

    dfd.promise

  @multiSearch: (keywords) -> 
    'aaa'
    dfd = Q.defer()
    promises = []

    for keyword in keywords 
      promises.push @search(keyword) 

    Q.all(promises).then (results) ->
      res = []

      for key, result of results
        # console.log 'FOO'
        # console.log result
        res.push result[0]
      console.log res
      res 
    # .then (results) ->
    #   console.log results


module.exports = Composta