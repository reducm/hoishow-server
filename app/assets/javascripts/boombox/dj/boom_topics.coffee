$ ->
  ## 列表刷新
  $(document).on 'change', '.topics_filter', ->
    $('#topics_form').submit()

  ## 发布
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
    dictFileTooBig: "单张图片最大10MB"
    dictInvalidFileType: "不支持该文件类型"
    dictMaxFilesExceeded: "最多上传9张图片"
    dictRemoveFile: "删除图片"
    maxFiles: 9
    maxFilesize: 10
    parallelUploads: 1
    init: ->
      @on 'success', (file, responseText) ->
        attachment_ids.push(responseText)
        $("#attachment_ids").attr("value", attachment_ids)
        file.previewTemplate.appendChild document.createTextNode "上传完毕"
        file.previewElement.lastElementChild.setAttribute('id', responseText)
        #console.log("@getAcceptedFiles().length: " + @getAcceptedFiles().length)
    addRemoveLinks: true
    removedfile: (file) ->
      id = file.previewElement.lastElementChild["id"]
      removedfile = file
      $.ajax
        type: 'POST',
        url: 'boom_topics/destroy_attachment.json',
        data: "id="+ id,
        dataType: 'json'
        success: (data, textStatus, xhr) ->
          removedfile.previewElement?.parentNode.removeChild removedfile.previewElement if removedfile.previewElement
          $.notify(xhr.responseJSON.message,
            position: "top center",
            className: 'success'
          )
        error: (xhr, textStatus, errorThrown) ->
          $.notify(xhr.responseJSON.message,
            position: "top center",
            className: 'error'
          )
      #console.log("@getAcceptedFiles().length: " + @getAcceptedFiles().length)
      #@_updateMaxFilesReachedClass()

  ## 详情页
  thumb_count = $('.thumb').length
  if thumb_count > 0
    if thumb_count > 1
      width = ($('#topic_thumbs').width() - 16 ) / 3 - 24
    else
      width = ($('#topic_thumbs').width() - 16 ) - 24
    $('.thumb').css('width', width)
    $('.thumb').css('height', width)
