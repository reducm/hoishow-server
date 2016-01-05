$ ->
  $(document).on 'change', '.collaborators_filter', ->
    $('#collaborators_form').submit()

  # 旧昵称
  original_nickname = $('#collaborator_nickname').val()

  # 标签
  all_tags = $("div#operation_collaborator_tags_data").data("data")
  $('#operation_collaborator_tags').tagit
    allowSpaces: true
    autocomplete: { delay: 0, minLength: 0, source: all_tags }
    showAutocompleteOnFocus: true

  # 昵称有修改时
  $('#collaborator_edit_btn').on 'click', (e) ->
    e.preventDefault()
    #昵称相关
    if $('#collaborator_nickname').val() != original_nickname
      if confirm('昵称一个月内只能修改一次，确定修改吗？')
        $("#collaborator-dropzone").submit()
    else
      $("#collaborator-dropzone").submit()
