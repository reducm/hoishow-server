#= require jquery
#= require jquery-ui
#= require jquery_ujs
#= require bootstrap-sprockets

$ ->
  if $('.description_content').length > 0
    $iframe = $('.video iframe')

    if /iPhone|iPad|iPod/i.test(navigator.userAgent)
      $iframe.hide()
      $('.video').append("<a href='#{$iframe.attr('src')}'>点击链接跳转</a>")
    else
      $iframe.css('height', $iframe.width() * 0.75)
