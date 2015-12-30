$ ->
  Dropzone.options.imageDzForm =
    acceptedFiles: ".jpg, .jpeg, .gif, .png"
    dictDefaultMessage: "选择图片或直接拖进来"
    dictFileTooBig: "单张图片最大10MB"
    dictInvalidFileType: "不支持该文件类型"
    maxFilesize: 10
    init: ->
      $('#upload_message').hide()
      @on 'sending', () ->
        $('#upload_message').fadeIn()
      @on 'success', (file, responseText) ->
        file.previewTemplate.appendChild document.createTextNode "上传完毕"
      @on 'queuecomplete', (file, responseText) ->
        $('#upload_message').fadeOut()
        document.location.reload()
