class Composta
  constructor: ->
    @cacheElements()
    @compileTemplates()
    @setSearchResultsPosition()
    @initializeSearchButton()

    @bindHandlers()
    @candidates = {}
    @charts     = {}


  search: (q) ->
    $.get "/search/#{q}"

  cacheElements: ->
    @$el             = $('body')
    @$input          = @$el.find '.js-input'
    @$search_button  = @$el.find '.js-submit'
    @$search_results = @$el.find '.js-search-results'
    @$candidates     = @$el.find '.js-candidates'
    @$candidate_info = @$el.find '.js-candidate-info'
    @$seach_tip      = @$el.find '.js-search-tip'
    @$charts         = @$el.find '.js-charts'

  compileTemplates: ->
    for k,v of Templates.source
      Templates.compiled[k] = Hogan.compile v

  startSearch: ->
    @search_button.start()
    @search(@$input.val())
      .then (response) =>
        @search_button.stop()
        @renderSearchResults response
        @cached_response = response

  addCandidate: (candidate) ->
    @$candidates.append Templates.compiled.candidate_list_item.render candidate
    @$candidates.find('.js-candidate:last .name').css 'color', candidate.color
    @renderCharts() if _.size(@candidates) > 1

  initializeSearchButton: () ->
    @search_button = Ladda.create @$search_button[0]

  setSearchResultsPosition: ->
    input_position = @$input.position()

    @$search_results.css
      left: input_position.left
      top:  input_position.top + 50

  renderSearchResults: (results) ->
    @$search_results.html Templates.compiled.search_results.render({ results: results })

  renderCandidateInfo: (candidate) ->
    @$candidate_info.html(Templates.compiled.candidate_info.render candidate)
                    .data('name', candidate.name)

  preprocessCandidates: ->
    @d3_candidates = []
    @d3_candidates.push v for k,v of @candidates

  renderCharts: (props = ['forks', 'followers', 'open_issues', 'age_seconds']) ->
    @$charts.html ''

    return if _.size(@candidates) is 0
    @preprocessCandidates()
    @renderChart v for k,v of props

  renderChart: (prop) ->
    x_axis = d3
      .scale.linear()
      .domain([0, d3.max(@d3_candidates, (el) -> el[prop])])
      .range([0, 700])

    @$charts.append Templates.compiled.chart.render {
      prop: prop
      normalized_prop: prop.replace '_', ' '
    }

    @charts[prop] = d3.select(".js-#{prop}")
      .append('svg')
      .attr('class', "chart #{prop}")
      .attr('width', 700)
      .attr('height', _.size(@d3_candidates) * 20)

    @charts[prop]
      .selectAll('rect')
      .data(@d3_candidates)
      .enter()
        .append('rect')
        .style('fill', (d) -> d.color)
        .attr('title', (d) -> d.name)
        .attr('y', (d, i) -> i * 20)
        .attr('width', (d, i) -> x_axis d[prop])
        .attr('height', 20)

    @charts[prop].selectAll("text")
      .data(@d3_candidates)
      .enter().append("text")
      .attr('x',(d, i) -> x_axis d[prop])
      .attr('y', (d, i) -> i * 20)
      .attr('dx', -5) # padding-right
      .attr('dy', 17) # vertical-align: middle
      .attr('text-anchor', 'end') # text-align: right
      .attr('style', 'color: #CCC')
      .text((d, i) -> d[prop]);

    @$el.find(".js-#{prop} rect").tipsy
      gravity: 'w',
      html: true,
      title: ->
        d = @.__data__
        "#{d.name}"


  bindHandlers: ->
    @$input.on 'keyup',                        (e) => @onQueryKeypress(e)
    @$search_button.on 'click',                => @startSearch()
    @$el.on 'click', '.js-result',             (e) => @onResultClick(e)
    @$el.on 'click', '.js-show-more',          (e) => @onCandidateShowMoreClick(e)
    @$el.on 'click', '.js-remove-candidate',   (e) => @onCandidateRemoveClick(e)
    @$el.on 'click', '.js-remove', => @onCandidateInfoRemoveClick()


    $(window).resize => @setSearchResultsPosition()

  onQueryKeypress: (e) ->
    if e.keyCode is 13
      @startSearch()
    if @$input.val() is ''
      @$search_results.html ''

  onResultClick: (e) ->
    index = $(e.currentTarget).index()
    @$search_results.html ''

    @$seach_tip.hide()

    if !@candidates[@cached_response[index]?.name]?
      new_candidate = @cached_response[index]
      new_candidate.color = "hsl(#{_.random(0,360)}, 50%, 50%)"
      @candidates[@cached_response[index].name] = new_candidate
      @addCandidate new_candidate


  onCandidateShowMoreClick: (e) ->
    $target = $(e.currentTarget)
    $parent = $target.parent('.js-candidate')
    name    = $parent.data 'name'

    @renderCandidateInfo @candidates[name]

  onCandidateInfoRemoveClick: ->
    @$candidate_info.html ''

  onCandidateRemoveClick: (e) ->
    $target = $(e.currentTarget)
    $parent = $target.parent('.js-candidate')
    name    = $parent.data 'name'

    @$candidate_info.hide() if @$candidate_info.data('name') is name

    delete @candidates[name]
    $parent.hide('slow').promise().then -> @remove()
    @renderCharts()



$ -> window.c = new Composta()