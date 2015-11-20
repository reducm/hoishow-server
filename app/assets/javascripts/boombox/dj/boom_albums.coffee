$ ->
  Dropzone.options.imageDzForm =
    acceptedFiles: ".jpg, .jpeg, .gif, .png"
    dictDefaultMessage: "选择文件或直接拖进来"
    dictFileTooBig: "文件太大，请重新选择"
    init: ->
        @on 'success', (file, responseText) ->
          file.previewTemplate.appendChild document.createTextNode "上传完毕"
          document.location.reload()
    maxFilesize: 10
