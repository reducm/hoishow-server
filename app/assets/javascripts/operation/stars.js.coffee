jQuery ->
  $('tbody').sortable(
    axis: 'y'
    update: ->
      $.post($(this).data('update-url'), $(this).sortable('serialize'))
      $('tbody').sortable("refresh")
      $.get 'operation/stars', (data) ->
        $('.tbody').html data
        return
  )
