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
    $.post("/operation/orders/#{order_id}/update_express_id", {content: content}, (data)->
      if data.success
        location.reload()
    )

  # 服务器提供的过滤条件数据源
  f_data = $('#orders_filters').data()

  # 订单列表初始化
  ShowOrders = do ->
    loadTable = ->
      if !jQuery().DataTable
        return
      orderTable = $("#orders_table").DataTable(
        # 基本配置
        stateSave: true
        ordering: false
        # 语言文件需要放服务器吗？
        language:
          url: "//cdn.datatables.net/plug-ins/1.10.9/i18n/Chinese.json"
        # 从服务器的Order#index获取数据
        processing: true
        serverSide: true
        # 把过滤条件回传服务器
        ajax:
          url: $("#orders_table").data("source")
          data: (d) ->
            $.extend {}, d,
              'status': $('#status_filter').val()
              'channel': $('#channel_filter').val()
              'buy_origin': $('#buy_origin_filter').val()
              'show': $('#show_filter').val()
              'start_date': $('#start_date_filter').val()
              'end_date': $('#end_date_filter').val()
        # 导出。这里有两个问题：csv导出不能；导出的是分页数据
        dom: "Blfrtip"
        buttons: ['excel']
        initComplete: ->
          api = @api()
          # 按支付状态过滤
          select = $('<select><option value="%%">支付状态：全部</option></select>').attr("id", "status_filter").appendTo($("#orders_table_length")).on 'change', ->
            api.ajax.reload()
          select.val("%%")
          $.each f_data["statusFilter"], (key, value) ->
            select.append '<option value="' + value + '">' + "支付状态：" + key + '</option>'
          # 按下单来源过滤
          select = $('<select><option value="%%">下单来源：全部</option></select>').attr("id", "channel_filter").appendTo($("#orders_table_length")).on 'change', ->
            api.ajax.reload()
          select.val("%%")
          $.each f_data["channelFilter"], (key, value) ->
            select.append '<option value="' + value + '">' + "下单来源：" + key + '</option>'
          # 按下单平台过滤
          select = $('<select><option value="%%">下单平台：全部</option></select>').attr("id", "buy_origin_filter").appendTo($("#orders_table_length")).on 'change', ->
            api.ajax.reload()
          select.val("%%")
          $.each f_data["buyOriginFilter"], (key, value) ->
            select.append '<option value="' + value + '">' + "下单平台：" + key + '</option>'
          # 按演出名称过滤
          select = $('<select><option value="%%">演出：全部</option></select>').attr("id", "show_filter").appendTo($("#orders_table_length")).on 'change', ->
            api.ajax.reload()
          select.val("%%")
          $.each f_data["showFilter"], (key, value) ->
            select.append '<option value="' + value + '">' + "演出：" + key + '</option>'
          # 按下单开始时间过滤
          input = $('<input></input>').attr('id', 'start_date_filter').attr('placeholder', '下单开始时间').appendTo($("#orders_table_length")).on 'change', ->
            api.ajax.reload()
          $('#start_date_filter').datetimepicker()
          # 按下单结束时间过滤
          input = $('<input></input>').attr('id', 'end_date_filter').attr('placeholder', '下单结束时间').appendTo($("#orders_table_length")).on 'change', ->
            api.ajax.reload()
          $('#end_date_filter').datetimepicker()
          # 文本搜索提示
          $('div#orders_table_filter.dataTables_filter label input').attr('placeholder', '手机号或订单号')
      )
    {
      init: ->
        loadTable()
    }

  jQuery(document).ready ->
    ShowOrders.init()
