#= require jquery
#= require jquery-ui
#= require tag-it
#= require jquery_ujs
#= require bootstrap-sprockets
#= require operation/sb-admin-2
#= require operation/metisMenu/metisMenu
#= require operation/bootstrap-select
#= require operation/echarts-all
#= require operation/notify
#
#= require boombox/dj/boom_albums
#= require boombox/dj/boom_topics
#= require boombox/dj/boom_comments
#= require boombox/dj/users
#= require boombox/dj/tracks
#= require boombox/dj/playlists
#
#= require jquery-fileupload
#= require dropzone
#= require datatables.min
#= require moment.min
#= require select2.full.min
#
#= require froala_editor.min
#= require plugins/char_counter.min
#= require plugins/emoticons.min
#= require languages/zh_cn
#
#= require simditor/module
#= require simditor/hotkeys
#= require simditor/uploader
#= require simditor/simditor
#= require simditor/beautify-html
#= require simditor/simditor-html

#= require jquery.qeditor

#= require operation/jquery.datetimepicker

$ ->
  #datetimepicker
  $('div.datetimepicker input').datetimepicker({
    format: 'Y-m-d H:i',
    startDate: new Date(),
    defaultDate: new Date(),
    lang: 'zh',
    step: 15,
    scrollInput: false
    })

  # 拉动排序, 调用jquery-ui的sortable
  # 需要排序的在元素的class加入dragable_items
  # 保存处理在controller
  $('.dragable_items').sortable(
    axis: 'y'
    handle: '.handle'
    update: ->
      $.post($(this).data('update-url'), $(this).sortable('serialize'))
      location.reload()
  )

  $('form').keypress((e)->
    return false if e.which == '13'
  )

  # 图片上传预览
  window.readURL = (input) ->
    if input.files and input.files[0]
      output_id = 'img-prv-' + $(input).attr('id')

      unless $('img#' + output_id)[0]
        $(input).parent().children().first().before('<img id=' + output_id + ' src="#"></img>')

      output = $('img#' + output_id)
      reader = new FileReader

      reader.onload = (e) ->
        $(output).attr 'src', e.target.result

        if $(output)[0].width > 700 or $(output)[0].height > 700
          $(output).css({
            'width' : '30%',
            'height' : '30%'
          })
        return

      reader.readAsDataURL input.files[0]
    return
