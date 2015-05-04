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

#show new form
  $("#show_city_select").attr("data-live-search", true)
  $("#show_city_select").selectpicker("refresh")
  $("#show_city_select").on "change", (e) ->
    select = $(e.currentTarget)
    selected_option = select.find("option:selected")
    city_id = selected_option.val()
    $.get("/operation/shows/get_city_stadiums", {city_id: city_id}, (data)->
      result = ""
      for stadium in data
        result += "<option value='#{stadium.id}'>#{stadium.name}</option>"
      $("#show_stadium_select").html(result)
      $("#show_stadium_select").attr("data-live-search", true)
      $("#show_stadium_select").selectpicker("refresh")
    )
