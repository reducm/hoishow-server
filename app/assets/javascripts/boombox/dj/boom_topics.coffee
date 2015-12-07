$ ->
  $(document).on 'change', '.topics_filter', ->
    $('#topics_form').submit()

  # 提交时，检测内容是否超出 140 字
  $('#topicForm input[type="submit"]').on 'click', (e) ->
    e.preventDefault()
    if $('#boom_topic_content').val().length > 140
      alert '抱歉！每条动态的字数上限为 140 字'
      return
    else if !/\S/.test($('#boom_topic_content').val())
      alert '动态内容为空'
      return
    else
      $("#topicForm").submit()
