#= require jquery
#= require jquery-ui
#= require jquery_ujs
#= require bootstrap-sprockets
#= require operation/sb-admin-2
#= require operation/metisMenu/metisMenu
#= require operation/bootstrap-select
#= require operation/echarts-all
#= require operation/stars
#= require operation/home
#= require operation/concerts
#= require operation/banners
#= require operation/shows
#= require operation/admins
#= require operation/orders
#= require operation/topics
#= require operation/comments
#= require operation/users
#= require operation/cities
#= require operation/tickets
#= require operation/messages
#= require operation/stadiums
#= require operation/startup
#= require dataTables/jquery.dataTables
#= require operation/notify
#= require jquery-fileupload/basic
#= require dropzone
#= require operation/videos

#= require simditor/module
#= require simditor/hotkeys
#= require simditor/uploader
#= require simditor/simditor
#= require simditor/beautify-html
#= require simditor/simditor-html

#= require operation/jquery.datetimepicker

#datetimepicker
$ ->
  $('div.datetimepicker input').datetimepicker({
    format: 'Y-m-d H:i',
    startDate: new Date(),
    defaultDate: new Date(),
    lang: 'zh',
    step: 15,
    scrollInput: false
    })

  $('.dragable_items').sortable(
    axis: 'y'
    handle: '.handle'
    update: ->
      $.post($(this).data('update-url'), $(this).sortable('serialize'))
      location.reload()
  )
