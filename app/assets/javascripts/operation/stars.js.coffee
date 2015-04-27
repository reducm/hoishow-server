$ ->
  $('#stars_list').sortable(
    axis: 'y'
    handle: '.handle'
    update: ->
      $.post($(this).data('update-url'), $(this).sortable('serialize'))
      location.reload()
  )

  $('#status_select').change ->
    $(".status_cn").parent().show()
    vtxt = $('#status_select').val()
    if vtxt == "全部"
      location.reload()
    else
      $(".status_cn:not(:contains('" + vtxt + "'))").parent().hide()

  
