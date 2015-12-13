#= require jquery
#= require jquery-ui
#= require jquery_ujs
#= require bootstrap-sprockets

$ ->
  if $('.description_content').length > 0
    $('p').each(()->
      if $(this).has('br').length > 0 && $(this).children().length == 1
        $(this).remove()
    )

    $iframe = $('iframe')
    if /iPhone|iPad|iPod/i.test(navigator.userAgent)
      $('.description_content').append("<div class='youku'><i class='icon'></i><a href='#{$('.video').data('url')}'>#{$('.video').data('title')}</a></div>")
      $('.video').remove()
    else
      $iframe.css('height', $iframe.width() * 0.75)
