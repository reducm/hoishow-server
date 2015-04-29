set_pie_cake = (left_count, sold_count, area_id) ->
    option =
      title:
        text: area_id
        x: "center"
      tooltip:
        show: true
      calculable: false
      series: [
        type: "pie"
        radius: "55%"
        data: [
          {value: sold_count, name: "售出数量"}
          {value: left_count, name: "剩余数量"}
        ]
      ]
    myChart = echarts.init(document.getElementById(area_id))
    myChart.setOption(option) 

$ ->
  if $(".shows_list")
    $(".shows").dataTable()

  $("#pie_cake div").each(() ->
    left_count = $(this).attr("left_count")
    sold_count = $(this).attr("sold_count")
    area_id = $(this).attr("id")
    set_pie_cake(left_count, sold_count, area_id))
