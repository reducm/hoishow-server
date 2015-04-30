set_pie_cake = (left_count, sold_count, area_name, tickets_count) ->
    option =
      title:
        text: area_name+"区(共"+tickets_count+"张)"
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
    myChart = echarts.init(document.getElementById(area_name))
    myChart.setOption(option) 

$ ->
  if $(".shows_list")
    $(".shows").dataTable()

  $("#pie_cake div").each(() ->
    left_count = $(this).attr("left_count")
    sold_count = $(this).attr("sold_count")
    area_name = $(this).attr("id")
    tickets_count = $(this).attr("total_tickets")
    set_pie_cake(left_count, sold_count, area_name, tickets_count))
