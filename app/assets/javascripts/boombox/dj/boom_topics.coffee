$ ->
  $(document).on 'change', '.topics_filter', ->
    $('#topics_form').submit()

  # 提交时，检测内容是否为空、去掉html标签、解密加密过的html内容
  $('#topicForm input[type="submit"]').on 'click', (e) ->
    e.preventDefault()
    if !/\S/.test($('#boom_topic_content_editor').val())
      alert '动态内容为空'
      return
    else
      content = $("#boom_topic_content_editor").val()
      striped_content = content.replace(/<(?:.|\n)*?>/gm, '')
      decoded_content = $('<textarea />').html(striped_content).text()
      $("#boom_topic_content").attr("value", decoded_content)
      $("#topicForm").submit()

  # 编辑器
  $('#boom_topic_content_editor').froalaEditor
    charCounterMax: 140
    language: 'zh_cn'
    multiLine: false
    pastePlain: true
    toolbarButtons: ['emoticons']
    toolbarButtonsMD: ['emoticons']
    toolbarButtonsSM: ['emoticons']
    toolbarButtonsXS: ['emoticons']

  if $('.fr-box').length > 0
    $('.fr-box a').remove()

  # 上传图片
  attachment_ids = []
  Dropzone.options.attachmentDzForm =
    acceptedFiles: ".jpg, .jpeg, .gif, .png"
    dictDefaultMessage: "选择图片或直接拖进来"
    dictFileTooBig: "文件太大，请重新选择"
    init: ->
      @on 'success', (file, responseText) ->
        attachment_ids.push(responseText)
        $("#attachment_ids").attr("value", attachment_ids)
        file.previewTemplate.appendChild document.createTextNode "上传完毕"
    maxFilesize: 10
