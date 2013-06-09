window.Templates = {
  source:
    search_results: """
    <ul>
    {{#results}}
      <li class="js-result result">
        <span class="owner">{{owner}}</span>/<span class="repo-name">{{name}}</span>
        <span class="language">{{language}}</span>
        <div class="stats">
          <span class="watchers stat"><i class="icon icon-star"></i>{{watchers}}</span>
          <span class="forks stat"><i class="icon icon-code-fork"></i>{{forks}}</span>
        </div>
      </li>
    {{/results}}
    </ul>
    """
    candidate_list_item: """
    <li class="candidate">
      <span class="repo-name">{{name}}</span>
      <button class="ladda-button js-show-more more" data-name="{{name}}">
        <i class="icon-caret-right"></i>
      </button>
    </li>
    """
    candidate_info: """
    <div class="more">
      <h4>Info about <span class="repo-name">{{name}}</span><span class="js-remove remove"><i class="icon-remove"></i></span></h4>
      <ul>
        <li>
          <label>url: </label>
          <span><a href="{{url}}" target="_blank">{{url}}</a></span>
        </li>
        <li>
          <label>age: </label>
          <span>{{created_ago}}</span>
        </li>
        <li>
          <label><i class="icon icon-code-fork"></i></label>
          <span>{{forks}}</span>
        </li>
        <li>
          <label><i class="icon icon-star"></i></label>
          <span>{{followers}}</span>
        </li>
        <li>
          <label>created at: </label>
          <span>{{created_at}}</span>
        </li>
        <li>
          <label>open issues: </label>
          <span>{{open_issues}}</span>
        </li>
        <li>
          <label>has wiki: </label>
          <span>{{has_wiki}}</span>
        </li>
        <li>
          <label>language: </label>
          <span>{{language}}</span>
      </li>
      </ul>
    </div>
    """
  compiled: {}
}