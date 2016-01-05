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

  if $('.video').length > 0
    $('.description_content').append("<div class='youku'><i class='icon'></i><a href='#{$('.video').data('url')}'>#{$('.video').data('title')}</a></div>")
    $('.video').remove()
