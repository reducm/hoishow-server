$ ->
  $(document).on 'change', '.collaborators_filter', ->
    $('#collaborators_form').submit()

  # 旧昵称
  original_nickname = $('#collaborator_nickname').val()

  # 标签
  if $('div#operation_collaborator_tags_already_added').length > 0
    data = $('div#operation_collaborator_tags_already_added').data('data')
    $('select#tags').val(data).select2()
  else
    $('select#tags').select2()

  # 昵称有修改时
  $('#collaborator_edit_btn').on 'click', (e) ->
    e.preventDefault()
    #提交前将标签id数组组装成字符串，并传入hidden field
    $("#boom_tag_ids").val($('select#tags').val())
    #昵称相关
    if $('#collaborator_nickname').val() != original_nickname
      if confirm('昵称一个月内只能修改一次，确定修改吗？')
        $("#collaborator-dropzone").submit()
    else
      $("#collaborator-dropzone").submit()
