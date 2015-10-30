# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  Dropzone.options.imageDzForm =
    acceptedFiles: ['jpg', 'jpeg', 'gif', 'png']
    dictDefaultMessage: "选择文件或直接拖进来"
    dictFileTooBig: "文件太大，请重新选择"
    init: ->
        @on 'success', (file, responseText) ->
          file.previewTemplate.appendChild document.createTextNode "上传完毕"
    maxFilesize: 10
