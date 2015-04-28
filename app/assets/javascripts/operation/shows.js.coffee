set_pie_cake = (a, b) ->
    option =
      tooltip:
        show: true
      calculable: false
      series: [
        type: "pie"
        radius: "55%"
        data: [
          {value: a, name: "售出数量"}
          {value: b, name: "剩余数量"}
        ]
      ]
    myChart = echarts.init(document.getElementById('pie_cake'))
    myChart.setOption(option) 

$ ->
  if $(".shows_list")
    $(".shows").dataTable()
  sold_count = $("#pie_cake").attr("sold_count")
  left_count = $("#pie_cake").attr("left_count")
  set_pie_cake(sold_count, left_count)
