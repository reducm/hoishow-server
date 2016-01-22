set_recent_data = (x_axis, y_axis) ->
  option =
    title :
      text: '近期数据汇总'
    tooltip :
      trigger: 'axis'
    legend:
      data: ['新增用户数']
    calculable : false
    xAxis : [
      type : 'category'
      data : x_axis
    ]
    yAxis : [
      type : 'value'
    ]
    series : [
      {
      name: '新增用户数'
      type: 'bar'
      data: y_axis
      }
    ]

  homeChart = echarts.init(document.getElementById("data_collection"))
  homeChart.setOption(option)

get_new_users_data = (time) ->
  $.get("/boombox/operation/home/get_new_users_data", {time: time}, (data)->
    if data.success
      set_recent_data(data.x_axis, data.y_axis)
  )

$ ->
  if $("#home").length > 0
    width = $('#home').width()
    $('#data_collection').width(width)
    get_new_users_data("seven_days_from_now")

    $(".select-begin-time a").on "click", (e)->
      $(".display-time").text(e.currentTarget.text)
      id_value = $(this).attr("id")
      get_new_users_data(id_value)
