$ ->
  if $('.express_detail').length > 0
    $('table tr').each((idx, e)->
      if idx == 0
        $(e).find('td:first').addClass('step-start')
      else
        $(e).find('td:first').addClass('step-point')
    )
    if $('#status').val() == '3'
      $('table tr:last').find('td:first').addClass('step-finish')

    td_width = $('body').width() * 0.75
    $('.detail').css('max-width': td_width)
