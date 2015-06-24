set_recent_data = (users_array, votes_array, orders_array, time_array) ->
  option =
    title :
      text: '近期数据汇总'
    tooltip :
      trigger: 'axis'
    legend:
      data:['新增用户量','成交总金额','新增投票数']
    calculable : false
    xAxis : [
      type : 'category'
      data : time_array
    ]
    yAxis : [
      type : 'value'
    ]
    series : [
      {
      name:'新增用户量'
      type:'line'
      data:users_array
      },
      {
      name:'成交总金额'
      type:'line'
      data:orders_array
      },
      {
      name:'新增投票数'
      type:'line'
      data:votes_array
      }
    ]

  homeChart = echarts.init(document.getElementById("data_collection"))
  homeChart.setOption(option)

$ ->
  $.get("/operation/home/get_graphic_data", {time: "this_month"}, (data)->
    if data.success
      $(".display-time").text(data.time_type)
      set_recent_data(data.users_array, data.votes_array, data.orders_array, data.time_array)
  )
  $(".select-begin-time a").on "click", ()->
    id_value = $(this).attr("id")
    $.get("/operation/home/get_graphic_data", {time: id_value}, (data)->
      if data.success
        $(".display-time").text(data.time_type)
        set_recent_data(data.users_array, data.votes_array, data.orders_array, data.time_array)
    )
