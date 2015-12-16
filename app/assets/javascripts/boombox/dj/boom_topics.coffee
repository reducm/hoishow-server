$ ->
  $(document).on 'change', '.topics_filter', ->
    $('#topics_form').submit()

  # 提交时，检测内容是否超出 140 字
  $('#topicForm input[type="submit"]').on 'click', (e) ->
    e.preventDefault()
    if !/\S/.test($('#boom_topic_content_editor').val())
      alert '动态内容为空'
      return
    else if $('#boom_topic_content_editor').val().length > 140
      alert '抱歉！每条动态的字数上限为 140 字'
      return
    else
      content = $("#boom_topic_content_editor").val()
      striped_content = content.replace(/<(?:.|\n)*?>/gm, '')
      $("#boom_topic_content").attr("value", striped_content)
      $("#topicForm").submit()

  # 编辑器
  $('#boom_topic_content_editor').froalaEditor
    language: 'zh_cn'
    multiLine: false
    pastePlain: true
    toolbarButtons: ['emoticons']
    toolbarButtonsMD: ['emoticons']
    toolbarButtonsSM: ['emoticons']
    toolbarButtonsXS: ['emoticons']
