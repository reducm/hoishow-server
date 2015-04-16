#= require jquery
#= require jquery_ujs
#= require bootstrap-sprockets
#= require kindeditor
#= require operation/sb-admin-2
#= require operation/metisMenu/metisMenu

#= require operation/jquery.datetimepicker

$ -> $('input.datetimepicker').datetimepicker({
  timepicker: false,
  format: 'd M Y',
  startDate: new Date(),
  value: new Date(),
  lang: 'zh'
});
