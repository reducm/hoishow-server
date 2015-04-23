#= require jquery
#= require jquery-ui
#= require jquery_ujs
#= require bootstrap-sprockets
#= require kindeditor
#= require operation/sb-admin-2
#= require operation/metisMenu/metisMenu
#= require operation/echarts-all
#= require operation/stars
#= require operation/concerts
#= require operation/shows
#= require operation/topics

#= require operation/jquery.datetimepicker

$ -> $('input.datetimepicker').datetimepicker({
  timepicker: false,
  format: 'd M Y',
  startDate: new Date(),
  value: new Date(),
  lang: 'zh'
});
