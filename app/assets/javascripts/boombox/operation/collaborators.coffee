$ ->
  $(document).on 'change', '.collaborators_filter', ->
    $('#collaborators_form').submit()

  # 旧昵称
  original_nickname = $('#collaborator_nickname').val()

  # 昵称有修改时
  $('input[type="submit"]').on 'click', (e) ->
    e.preventDefault()
    if $('#collaborator_nickname').val() != original_nickname
      if confirm('昵称一个月内只能修改一次，确定修改吗？')
        $(this).parents('form').submit()
    else
      $(this).parents('form').submit()
