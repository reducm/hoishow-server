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
  PICS = {}
  $("#show_city_select").attr("data-live-search", true)
  $("#show_city_select").selectpicker("refresh")
  $("#show_city_select").on "change", (e) ->
    select = $(e.currentTarget)
    selected_option = select.find("option:selected")
    city_id = selected_option.val()
    $.get("/operation/shows/get_city_stadiums", {city_id: city_id}, (data)->
      result = ""
      PICS = {}
      for stadium in data
        result += "<option value='#{stadium.id}'>#{stadium.name}</option>"
        PICS[stadium.id] = stadium.pic
      $("#show_stadium_select").html(result)
      $("#show_stadium_select").attr("data-live-search", true)
      $("#show_stadium_select").selectpicker("refresh")
      $("#stadium_pic").attr("src", data[0]["pic"]) 
    )

  #change stadium pic
  $("#show_stadium_select").on "change", (e) ->
    select = $(e.currentTarget)
    selected_option = select.find("option:selected")
    stadium_id = selected_option.val()
    $("#stadium_pic").attr("src", PICS[stadium_id])
  
  #change area data
  $("#show_area").on "click", ".change_show_area_data", (e) ->
    area_id = $(this).data("area-id")
    seats_count = $("#td_seats_count_#{area_id}").text()
    $("#td_seats_count_#{area_id}").html("<input type='text' class='form-control' value='#{seats_count}' id='seats_count_#{area_id}'>")
    price = $("#td_price_#{area_id}").text()
    $("#td_price_#{area_id}").html("<input type='text' class='form-control' value='#{price}' id='price_#{area_id}'>")
    $(this).parent().html("<button  data-area-id='#{area_id}' class='change_submit'>确定</button>")
    
  $("#show_area").on "click", ".change_submit", (e) ->
    area_id = $(this).data("area-id")
    seats_count = $("input#seats_count_#{area_id}").val()
    sold_tickets = $("#sold_tickets_#{area_id}").text()
    show_id = $("#show_id").val()
    price = $("input#price_#{area_id}").val()
    if (parseInt(price) <= 0)
      alert("价格必须全为数字")
      return false
    if (parseInt(seats_count) <= 0)
      alert("座位数必须全为数字")
      return false
    if parseInt( seats_count ) < parseInt( sold_tickets )
      alert("座位数不能少于售出票数")
    else
      $.post("/operation/shows/#{show_id}/update_area_data", {show_id: show_id, area_id: area_id, seats_count: seats_count, price: price}, (data)->
        $("#show_area").html(data)
      )
