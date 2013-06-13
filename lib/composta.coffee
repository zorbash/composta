moment = require 'moment'
Q      = require 'q'



class Composta
  @search: (query) ->
    dfd = Q.defer()
    @github.search.repos { keyword: query.params.q }, (err, response) ->
      if response.repositories?
        repos = response.repositories[0...10]
        for k,v of repos
          parsed_date = moment(v.created_at[0...10], 'YYYY-MM-DD')

          v.created_ago = parsed_date.fromNow()
            .replace('ago', '')
            .trim()
          v.created_at = parsed_date.format 'DD-MM-YYYY'
          v.age_seconds = ~~(parseInt(parsed_date.format('X'), 10) / (3600 * 24))
        dfd.resolve repos
    dfd


module.exports = Composta