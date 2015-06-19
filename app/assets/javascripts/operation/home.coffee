set_recent_data = (users_array, votes_array, orders_array) ->
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
      data : ['6天前','5天前','4天前','3天前','2天前','昨天','今天']
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

  homeChart = echarts.init(document.getElementById("recent_data"))
  homeChart.setOption(option)

$ ->
  users_array = $("#recent_data").data("users")
  orders_array = $("#recent_data").data("orders")
  votes_array = $("#recent_data").data("votes")
  set_recent_data(users_array, orders_array, votes_array)
