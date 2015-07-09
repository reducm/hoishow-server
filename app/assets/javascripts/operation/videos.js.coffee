$ ->
  Dropzone.options.dzForm =
    acceptedFiles: ".mp4"
    dictDefaultMessage: "选择文件或直接拖进来"
    dictFileTooBig: "文件太大，请重新选择"
    init: ->
        @on 'success', (file, responseText) ->
          file.previewTemplate.appendChild document.createTextNode "上传完毕"
    maxFilesize: 30
