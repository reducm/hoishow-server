$ ->
  # 标签
  all_tags = $("div#dj_collaborator_tags_data").data("data")
  $('#dj_collaborator_tags').tagit
    allowSpaces: true
    autocomplete: { delay: 0, minLength: 0, source: all_tags }
    showAutocompleteOnFocus: true
