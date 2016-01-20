set_recent_data = (users_array, time_array) ->
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
      data : time_array
    ]
    yAxis : [
      type : 'value'
    ]
    series : [
      {
      name: '新增用户数'
      type: 'bar'
      data: users_array
      }
    ]

  homeChart = echarts.init(document.getElementById("data_collection"))
  homeChart.setOption(option)

get_graphic_data = (time) ->
  $.get("/boombox/operation/home/get_graphic_data", {time: time}, (data)->
    if data.success
      $(".display-time").text(data.time_type)
      set_recent_data(data.users_array, data.time_array)
  )

$ ->
  if $("#home").length > 0
    width = $('#home').width()
    $('#data_collection').width(width)
    get_graphic_data("seven_days_from_now")

    $(".select-begin-time a").on "click", ()->
      id_value = $(this).attr("id")
      get_graphic_data(id_value)
