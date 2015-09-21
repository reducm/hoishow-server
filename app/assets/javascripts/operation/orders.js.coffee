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

  # 快递单搜索重置
  $('#express_reset').on 'click', ->
    $('input#q_express').val('')
    location.reload

  # 服务器提供的过滤条件数据源
  f_data = $('#orders_filters').data()

  # 返回当前季节的开始日期
  season_start_date = ->
    current_month = moment().format('M')
    switch current_month
      when "3", "4", "5"
        moment().format('YYYY/03/01 00:00')
      when "6", "7", "8"
        moment().format('YYYY/06/01 00:00')
      when "9", "10", "11"
        moment().format('YYYY/09/01 00:00')
      when "12", "1", "2"
        moment().format('YYYY/12/01 00:00')
      else
        alert "sth wrong", current_month

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
          url: "/Chinese.json"
        # 从服务器的Order#index获取数据
        processing: true
        serverSide: true
        # 导出excel
        dom: 'Blfrtip'
        buttons: [
          text: '导出excel'
          extend: 'excel'
        ]
        # 把过滤条件回传服务器
        ajax:
          url: $("#orders_table").data("source")
          data: (d) ->
            $.extend {}, d,
              'status': $('#status_filter').val()
              'channel': $('#channel_filter').val()
              'buy_origin': $('#buy_origin_filter').val()
              # 从演出详情页访问的话，取该演出的订单
              'show': if $('#show_id').length > 0 then $('#show_id').data()["thisShowId"] else $('#show_filter').val()
              'start_date': $('#start_date_filter').val()
              'end_date': $('#end_date_filter').val()
              'orders_all_page': $('#orders_all_page_filter').val()
        initComplete: ->
          api = @api()
          # 分页标识
          select = $('<select><option selected="selected" value="0">分页</option></select>').attr("id", "orders_all_page_filter").addClass('form-control orders_filters').appendTo($("#orders_table_length")).on 'change', ->
            if $(this).val() == '1'
              $('#orders_table_length label:first').hide()
              $('#orders_table_info').hide()
              $('#orders_table_paginate').hide()
            else
              $('#orders_table_length label:first').show()
              $('#orders_table_info').show()
              $('#orders_table_paginate').show()
            api.ajax.reload()
          select.append '<option value="1">' + "不分页" + '</option>'
          # 按支付状态过滤
          select = $('<select><option selected="selected" value="">支付状态：全部</option></select>').attr("id", "status_filter").addClass('form-control orders_filters').appendTo($("#orders_table_length")).on 'change', ->
            api.ajax.reload()
          $.each f_data["statusFilter"], (key, value) ->
            select.append '<option value="' + value + '">' + "支付状态：" + key + '</option>'
          # 按下单来源过滤
          select = $('<select><option selected="selected" value="">下单来源：全部</option></select>').attr("id", "channel_filter").addClass('form-control orders_filters').appendTo($("#orders_table_length")).on 'change', ->
            api.ajax.reload()
          $.each f_data["channelFilter"], (key, value) ->
            select.append '<option value="' + value + '">' + "下单来源：" + key + '</option>'
          # 按下单平台过滤
          select = $('<select><option selected="selected" value="">下单平台：全部</option></select>').attr("id", "buy_origin_filter").addClass('form-control orders_filters').appendTo($("#orders_table_length")).on 'change', ->
            api.ajax.reload()
          $.each f_data["buyOriginFilter"], (key, value) ->
            select.append '<option value="' + value + '">' + "下单平台：" + key + '</option>'
          # 按演出过滤
          # 如果从演出详情页访问的，不生成过滤框
          unless $('#show_id').length > 0
            select = $('<select><option selected="selected" value="">演出：全部</option></select>').attr("id", "show_filter").addClass('form-control orders_filters').appendTo($("#orders_table_length")).on 'change', ->
              api.ajax.reload()
            $.each f_data["showFilter"], (key, value) ->
              select.append '<option value="' + value + '">' + "演出：" + key + '</option>'
          # 时间过滤预设
          timenow = moment().format('YYYY/MM/DD hh:mm')
          # 时间过滤预设：全部
          $('<br />').appendTo($("#orders_table_length"))
          $('<button>全部</button>').addClass('btn btn-default orders_buttons').appendTo($("#orders_table_length")).on 'click', ->
            $('#start_date_filter').val("")
            $('#end_date_filter').val("")
            api.ajax.reload()
          # 时间过滤预设：今天
          $('<button>今天</button>').addClass('btn btn-default orders_buttons').appendTo($("#orders_table_length")).on 'click', ->
            $('#start_date_filter').val(moment().format('YYYY/MM/DD 00:00'))
            $('#end_date_filter').val(timenow)
            api.ajax.reload()
          # 时间过滤预设：本周
          $('<button>本周</button>').addClass('btn btn-default orders_buttons').appendTo($("#orders_table_length")).on 'click', ->
            $('#start_date_filter').val(moment().startOf('week').format('YYYY/MM/DD 00:00'))
            $('#end_date_filter').val(timenow)
            api.ajax.reload()
          # 时间过滤预设：本月
          $('<button>本月</button>').addClass('btn btn-default orders_buttons').appendTo($("#orders_table_length")).on 'click', ->
            $('#start_date_filter').val(moment().startOf('month').format('YYYY/MM/DD 00:00'))
            $('#end_date_filter').val(timenow)
            api.ajax.reload()
          # 时间过滤预设：本季
          $('<button>本季</button>').addClass('btn btn-default orders_buttons').appendTo($("#orders_table_length")).on 'click', ->
            $('#start_date_filter').val(season_start_date)
            $('#end_date_filter').val(timenow)
            api.ajax.reload()
          # 时间过滤预设：本年
          $('<button>本年</button>').addClass('btn btn-default orders_buttons').appendTo($("#orders_table_length")).on 'click', ->
            $('#start_date_filter').val(moment().startOf('year').format('YYYY/MM/DD 00:00'))
            $('#end_date_filter').val(timenow)
            api.ajax.reload()
          # 按下单开始时间过滤
          $('<br />').appendTo($("#orders_table_length"))
          input = $('<input></input>').attr('id', 'start_date_filter').attr('placeholder', '订单时间').addClass('form-control date_range').appendTo($("#orders_table_length")).on 'change', ->
            api.ajax.reload()
          $('<label>至</label>').appendTo($("#orders_table_length"))
          $('#start_date_filter').datetimepicker()
          # 按下单结束时间过滤
          input = $('<input></input>').attr('id', 'end_date_filter').attr('placeholder', '订单时间').addClass('form-control date_range').appendTo($("#orders_table_length")).on 'change', ->
            api.ajax.reload()
          $('#end_date_filter').datetimepicker()
          # 重置
          $('<button>重置所有条件</button>').addClass('btn btn-default orders_buttons').appendTo($("#orders_table_length")).on 'click', ->
            $('#status_filter').val('')
            $('#channel_filter').val('')
            $('#buy_origin_filter').val('')
            $('#show_filter').val('')
            $('#start_date_filter').val('')
            $('#end_date_filter').val('')
            api.search('').draw()
          # 文本搜索提示
          $('div#orders_table_filter.dataTables_filter label input').attr('placeholder', '手机号或订单号').removeClass('input-sm')
    )
    {
      init: ->
        loadTable()
    }

  jQuery(document).ready ->
    ShowOrders.init()

    # 页面（主要是快递单详情）刷新后，保持显示之前浏览的tab
    $('a[data-toggle="tab"]').on 'shown.bs.tab', (e) ->
      sessionStorage.setItem 'activeTab', $(e.target).attr('href')
    activeTab = sessionStorage.getItem('activeTab')
    if activeTab
      $('#orderTab a[href="' + activeTab + '"]').tab 'show'

    
