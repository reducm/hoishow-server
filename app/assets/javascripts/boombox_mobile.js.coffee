#= require jquery
#= require jquery-ui
#= require jquery_ujs
#= require bootstrap-sprockets

$ ->
  if $('.description_content').length > 0
    $iframe = $('.video iframe')
    $iframe.css('height', $iframe.width() * 0.75)
