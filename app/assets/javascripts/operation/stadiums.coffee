$ ->
  if $('.stadium').length > 0
    $('.select, input').removeClass('form-control')

  $('.submit_stadium').on 'click', (e)->
    e.preventDefault()

    result = ''
    $('#stadium_latitude, #stadium_longitude, #stadium_address, #stadium_name').each(()->
      if $(this).val().length < 1
        result += "#{$(this).prev().text()} "
        $(this).addClass('error')
      else
        $(this).removeClass('error')
    )

    if result.length > 0
      alert result += '不能为空'
    else
      $(this).parents('form').submit()