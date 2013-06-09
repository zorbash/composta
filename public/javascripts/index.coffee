class Composta
  constructor: ->
    @cacheElements()
    @compileTemplates()
    @setSearchResultsPosition()
    @initializeSearchButton()

    @bindHandlers()
    @candidates = {}


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
    @$candidate_info.html Templates.compiled.candidate_info.render candidate


  bindHandlers: ->
    @$input.on 'keyup',               (e) => @onQueryKeypress(e)
    @$search_button.on 'click',       => @startSearch()
    @$el.on 'click', '.js-result',    (e) => @onResultClick(e)
    @$el.on 'click', '.js-show-more', (e) => @onCandidateShowMoreClick(e)
    @$el.on 'click', '.js-remove',    => @onCandidateInfoRemoveClick()


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
      @candidates[@cached_response[index].name] = new_candidate
      @addCandidate new_candidate


  onCandidateShowMoreClick: (e) ->
    $target = $(e.currentTarget)
    name = $target.data 'name'

    @renderCandidateInfo @candidates[name]

  onCandidateInfoRemoveClick: ->
    @$candidate_info.html ''


$ -> new Composta()