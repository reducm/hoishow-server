$ ->
  $('#order_status_select').change ->
    $(".order_status_cn").parent().show()
    vtxt = $('#order_status_select').val()
    if vtxt == "全部"
      location.reload()
    else
      $(".order_status_cn:not(:contains('" + vtxt + "'))").parent().hide()

  if $(".orders_list").length > 0
    $(".orders").dataTable()

#修改快递单号
  $("#express_id").on "click", ".change_express_content", (e) ->
    e.preventDefault()
    order_id = $("#order_id").val()
    content = $("#express_content").val()
    if content.length < 1
      alert("不能发空回复")
    else
      $.post("/operation/orders/#{order_id}/update_express_id", {content: content }, (data)->
        if data.success
          location.reload()
      )

