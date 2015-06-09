$ ->
#修改快递单号
  $("#expresses_list").on "click", ".change_express_data", (e) ->
    e.preventDefault()
    order_id = $(this).data("order-id")
    express_id = $("#td_express_id_#{order_id}").text()
    $("#td_express_id_#{order_id}").html("<input type='text' class='form-control' value='#{express_id}' id='express_id_#{order_id}'>")
    $(this).parent().html("<button  data-order-id='#{order_id}' class='btn btn-info express_content_change_submit'>确定</button>")
    
  $("#expresses_list").on "click", ".express_content_change_submit", (e) ->
    e.preventDefault()
    order_id = $(this).data("order-id")
    content = $("#express_id_#{order_id}").val()
    $.post("/operation/orders/#{order_id}/update_express_id", {content: content, order_id: order_id }, (data)->
      if data.success
        location.reload()
    )

