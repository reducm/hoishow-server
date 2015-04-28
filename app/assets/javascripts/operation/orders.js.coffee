$ ->
  $('#order_status_select').change ->
    $(".order_status_cn").parent().show()
    vtxt = $('#order_status_select').val()
    if vtxt == "全部"
      location.reload()
    else
      $(".order_status_cn:not(:contains('" + vtxt + "'))").parent().hide()

  if $(".orders_list")
    $(".orders").dataTable()
#票码弹出
  $("[data-toggle='popover']").popover({html : true})
