set_pie_cake = (left_count, sold_count, area_name, tickets_count) ->
    option =
      title:
        text: area_name + "区(共" + tickets_count + "张)"
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
  $("#pie_cake div").each(() ->
    left_count = $(this).attr("left_count")
    sold_count = $(this).attr("sold_count")
    area_name = $(this).attr("id")
    tickets_count = $(this).attr("total_tickets")
    set_pie_cake(left_count, sold_count, area_name, tickets_count))

#show new form
  if $(".new_show").length > 0
    PICS = {}
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

  #change area data
  $("#show_areas").on "click", ".change_show_area_data", () ->
    area_id = $(this).parent().data("id")
    show_id = $("#show_id").val()
    price = $(".price_#{area_id} input").val()
    area_name = $(".area_name_#{area_id} input").val()
    seats_count = $(".seats_count_#{area_id} input").val()
    sold_tickets = $(".sold_tickets_#{area_id}").text()
    if (parseFloat(price) <= 0)
      alert("价格必须为数字")
      return false
    if (parseInt(seats_count) <= 0)
      alert("座位数必须为整数")
      return false
    if parseInt(seats_count) < parseInt(sold_tickets)
      alert("座位数不能少于售出票数")
    else
      $.post("/operation/shows/#{show_id}/update_area_data", {area_id: area_id, area_name: area_name, seats_count: seats_count, price: price}, (data)->
        $("#show_area").html(data)
        alert("修改成功")
      )
