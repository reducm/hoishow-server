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

set_title = (el)->
  seat_no = $(el).data('seat-no')
  price = if parseFloat($(el).data('seat-price')) then parseFloat($(el).data('seat-price')) else 0
  text = "座位号: #{seat_no} 价格: #{price}"
  $(el).attr('data-original-title', text)
  $('ul.seats span').tooltip()

get_seats_info = ()->
  show_id = $('#show_id').val()
  area_id = $('#area_id').val()
  area_name = $('#area_name').val()
  sort_by = $('#area_sort_by').val()
  seats = []
  $('ul.seats li').each(()->
    $li = $(this)
    row_seats = []
    $li.children().each(()->
      row_seats.push({row: $(this).data('row-id'), column: $(this).data('column-id'), seat_status: $(this).data('status'), seat_no: $(this).data('seat-no'), price: $(this).data('seat-price')})
    )
    seats.push(row_seats)
  )
  result = {seats: seats, sort_by: sort_by}
  $.post("/operation/shows/#{show_id}/update_seats_info", {area_id: area_id, seats_info: JSON.stringify(result), area_name: area_name, sort_by: sort_by}, (data)->
    if data.success
      location.href = "/operation/shows/#{show_id}/edit"
  )
$ ->
#show show
  if $(".show_show").length > 0
    $("#pie_cake div").each(() ->
      left_count = $(this).attr("left_count")
      sold_count = $(this).attr("sold_count")
      area_name = $(this).attr("id")
      tickets_count = $(this).attr("total_tickets")
      set_pie_cake(left_count, sold_count, area_name, tickets_count))

#show new form
  if $(".new_show").length > 0
    $('#show_stadium_select').prev().after("<a class='add_stadium' target='_blank'>添加场馆</a>")
    $("#show_city_select").attr("data-live-search", true)
    $("#show_city_select").selectpicker("refresh")
    $("#show_city_select").on "change", (e) ->
      select = $(e.currentTarget)
      selected_option = select.find("option:selected")
      city_id = selected_option.val()
      $('.add_stadium').attr('href', "/operation/stadiums/new?city_id=#{city_id}")
      $.get("/operation/shows/get_city_stadiums", {city_id: city_id}, (data)->
        result = ""
        for stadium in data
          result += "<option value='#{stadium.id}'>#{stadium.name}</option>"

        if result
          $("#show_stadium_select").html(result)
        else
          $('#show_stadium_select').html('<option>所选城市暂无场馆</option>')

        $("#show_stadium_select").attr("data-live-search", true)
        $("#show_stadium_select").selectpicker("refresh")
      )

    $(".submit-form").on('click', (e) ->
      e.preventDefault()
      if $("#show_stadium_select").val().length < 1
        alert('场馆不能为空，请重新选择')
      else
        $(this).parents('form').submit()
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


  # 删除topic
  $(".show_show_topics_list").on "click", ".del_topic", ()->
    if confirm("确定要删除?")
      topic_id = $(this).parent().data("id")
      $.post("/operation/topics/#{topic_id}/destroy_topic", {_method: 'delete'}, (data)->
        if data.success
          location.reload()
      )

  # 设置选座
  if $('.seats-info').length > 0
    $('ul.seats').selectable({filter: 'span'})

    $('ul.seats span').tooltip()

    #设置行列
    $('.set_box').on 'click', ()->
      row_size = $('#row_size').val()
      column_size = $('#column_size').val()
      if row_size < 1 || column_size < 1
        alert('行和列不能为空')
      else if isNaN(row_size) || isNaN(column_size)
        alert('行和列必须为数字')
      else
        $('ul.seats').children().remove()
        i = 0
        while i < row_size
          $('ul.seats').append '<li class=\'row_' + (i + 1) + '\'></li>'
          j = 0
          while j < column_size
            $('li.row_' + (i + 1)).append '<span title=\'\' class=\'seat blank\' data-seat-no=\'\' data-row-id=\'' + (i + 1) + '\' data-column-id=\'' + (j + 1) + '\'></span'
            j++
          i++
        $('ul.seats').selectable({filter: 'span'})

    #设置座位状态
    $('.set_avaliable').on 'click', ()->
      $('.ui-selected').data('status', 'avaliable').addClass('avaliable').removeClass('locked unused ui-selected blank no-status')

    $('.set_locked').on 'click', ()->
      $('.ui-selected').data('status', 'locked').addClass('locked').removeClass('avaliable unused ui-selected blank no-status')

    $('.set_unused').on 'click', ()->
      $('.ui-selected').data('status', 'unused').addClass('unused').removeClass('locked avaliable ui-selected blank no-status')

    #设置座位号
    $(".set_seat_no").on 'click', ()->
      $seat = $(".ui-selected")
      if $seat.length != 1
        alert('一次只能修改一个座位')
      else
        seat_no = prompt('请输入座位号')
        if seat_no
          $seat.data('seat-no', seat_no)
          set_title('.ui-selected')

    #设置价格
    $('.set_price').on 'click', ()->
      $seats = $(".ui-selected")
      if $seats.length < 1
        alert('必须选中座位才能设置价格')
      else
        price = prompt('请输入价格')
        if price && parseFloat(price) > 0
          $seats.data('seat-price', price).each((idx, el)->
            set_title(el)
          )
        else
          alert('价格必须为数字')

    #提交
    $('.submit_seats').on 'click', ()->
      if $('ul.seats span').length < 1
        return false
      else if $('.blank').length > 0
        alert('还有座位没有设置状态')
        $('.blank').addClass('no-status')
      else
        get_seats_info()
