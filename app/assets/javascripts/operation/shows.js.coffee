set_pie_cake = (unpaid_count, left_count, sold_count, area_name, tickets_count) ->
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
          {value: unpaid_count, name: "未支付数量"}
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
      row_seats.push({row: $(this).data('row-id'), column: $(this).data('column-id'), seat_status: $(this).data('status'), seat_no: $(this).data('seat-no'), price: $(this).data('seat-price'), channel_ids: $(this).data('channel-ids')})
    )
    seats.push(row_seats)
  )
  result = {seats: seats, sort_by: sort_by}
  $.post("/operation/shows/#{show_id}/update_seats_info", {area_id: area_id, seats_info: JSON.stringify(result), area_name: area_name, sort_by: sort_by}, (data)->
    if data.success
      location.href = "/operation/shows/#{show_id}/edit"
  )

init_editor = ()->
  editor = new Simditor({
             textarea: $('#show_description'),
             upload: {
               url: '/simditor_image',
               connectionCount: 3,
               leaveConfirm: '正在上传文件，如果离开上传会自动取消'
             },
             toolbar: ['link', 'image', '|', 'title', 'bold', 'italic', 'color','|', 'underline', 'strikethrough', 'hr', 'html'],
             pasteImage: true
           })

toggle_show_time = ()->
  $('#show_status').on 'change', ()->
    if $(this).val() == 'going_to_open'
      $('.show_description_time').show()
      $('.show_show_time').hide()
    else
      $('.show_description_time').hide()
      $('.show_show_time').show()

  if $('#show_status').val() == 'going_to_open'
    $('.show_description_time').show()
    $('.show_show_time').hide()
  else
    $('.show_description_time').hide()
    $('.show_show_time').show()
$ ->
  $('.image-uploader').change ->
    readURL this

  init_editor() if $('#show_description').length > 0
#show show
  if $(".show_show").length > 0
    $("#pie_cake div").each(() ->
      left_count = $(this).attr("left_count")
      sold_count = $(this).attr("sold_count")
      unpaid_count = $(this).attr("unpaid_count")
      area_name = $(this).attr("id")
      tickets_count = $(this).attr("total_tickets")
      if tickets_count > 0
        $(this).width(300).height(300)
        set_pie_cake(unpaid_count, left_count, sold_count, area_name, tickets_count))

#show new form
  if $(".new_show").length > 0
    toggle_show_time()

    $('.add_star').on 'click', ()->
      $selected = $('#select_star option:selected')
      if $selected.val()
        star_id = $selected.val()
        star_name = $selected.text()
        $selected.remove()
        $('.stars').append("<span class='btn btn-default' data-id='#{star_id}'>#{star_name}</span><a class='del_star btn btn-danger'>删除</a>")

    $('.stars').on 'click', '.del_star', ()->
      $span = $(this).prev()
      $('#select_star').append("<option value='#{$span.data('id')}'>#{$span.text()}</option>")
      $span.remove()
      $(this).remove()

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

    $(".submit-form").on 'click', (e) ->
      e.preventDefault()
      if $("#show_stadium_select").val().length < 1
        alert('场馆不能为空，请重新选择')
      else if $("div.stars span").length < 1
        alert('艺人不能为空，请重新选择')
      else if $("#show_name").val().length < 1
        alert('演出名称不能为空，请填写')
      else if $('div.show_ticket_type input[type=radio]:checked').size() < 1
        alert('取票方式不能为空，请重新选择')
      else
        ids = $('.stars span').map(()->
          return $(this).data('id')
        ).toArray().join(',')
        $form = $(this).parents('form')
        $form.append("<input type='hidden' value='#{ids}' name='star_ids'/>")
        $form.submit()

  if $('.edit_show').length > 0
    toggle_show_time()
    show_id = $("#show_id").val()

    $('.add_star').on 'click', ()->
      star_id = $("#select_star").val()
      $.post("/operation/shows/#{show_id}/add_star", {star_id: star_id}, (data)->
        if data.success
          location.reload()
      )
    $('.stars').on 'click', '.del_star', ()->
      star_id = $(this).prev().data("id")
      if confirm('确定要删除该艺人吗')
        $.post("/operation/shows/#{show_id}/del_star", {star_id: star_id, _method: 'delete'}, (data)->
          if data.success
            location.reload()
        )


    $('.add_area').on 'click', ()->
      name = prompt('请输入区域名称')
      if name.length > 0
        $.post("/operation/shows/#{show_id}/new_area", {area_name: name}, (data)->
          $('.areas tbody').html(data)
        )
      else
        alert('区域名不能为空')

    $('.areas').on 'click', '.del_area', ()->
      if confirm('确定要删除该区域吗')
        area_id = $(this).parent().data('id')
        if area_id
          $.post("/operation/shows/#{show_id}/del_area", {area_id: area_id, _method: 'delete'}, (data)->
            $('.areas tbody').html(data)
          )
        else
          $(this).parents('tr').remove()

    #change area data
    $("#show_areas").on "click", ".change_show_area_data", () ->
      area_id = $(this).parent().data("id")
      price = $(".price_#{area_id} input").val()
      area_name = $(".area_name_#{area_id} input").val()
      seats_count = $(".seats_count_#{area_id} input").val()
      sold_tickets = $(".sold_tickets_#{area_id}").text()
      if (parseFloat(price) < 0.0)
        alert("价格必须为数字且不能少于0")
        return false
      if (parseInt(seats_count) < 0)
        alert("座位数必须为整数")
        return false
      if parseInt(seats_count) < parseInt(sold_tickets)
        alert("座位数不能少于售出票数")
      else
        $.post("/operation/shows/#{show_id}/update_area_data", {area_id: area_id, area_name: area_name, seats_count: seats_count, price: price}, (data)->
          $('.areas tbody').html(data)
          alert("修改成功")
        )

    #设置渠道
    $('.areas').on 'click', '.set_channel', ()->
      $td = $(this).parent()
      $('#area_id').val($td.data('id'))
      $('.channels input[type="checkbox"]').each(()->
        if $td.data('channels').indexOf($(this).val()) > -1
          $(this).prop('checked', true)
        else
          $(this).prop('checked', false)
      )
      $('#setChannelModal').modal('show')

    #全选
    $('#setChannelModal').on 'click', '#check_all', ()->
      $('.channels input[type="checkbox"]').prop('checked', $(this).prop('checked'))

    $('#setChannelModal').on 'click', '.channels input[type="checkbox"]', ()->
      $('#check_all').prop('checked', $('.channels input[type="checkbox"]:checked').length == $('.channels input[type="checkbox"]').length)

    #反选
    $('#setChannelModal').on 'click', '#anti_all', ()->
      $('.channels input[type="checkbox"]').each(()->
        $(this).prop('checked', !this.checked)
      )

    $('#setChannelModal').on 'click', '.submit_channel', (e)->
      e.preventDefault()
      if $('.channels input[type="checkbox"]:checked').length < 1
        alert('请选择一个渠道')
      else
        ids = $('.channels input[type="checkbox"]:checked').map(()->
                return $(this).val()
              ).toArray()
        $.post("/operation/shows/#{show_id}/set_area_channels", {area_id: $('#area_id').val(), ids: ids}, (data)->
          $('#setChannelModal').modal('hide')
          $('.areas tbody').html(data)
          alert('渠道设置成功')
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

    #设置渠道
    $('.set_channel').on 'click', ()->
      $seats = $('.ui-selected')
      if $seats.length < 1
        alert('必须选中座位才能设置渠道')
      else
        $('#setChannelModal').modal('show')

    #全选
    $('#setChannelModal').on 'click', '#check_all', ()->
      $('.channels input[type="checkbox"]').prop('checked', $(this).prop('checked'))

    $('#setChannelModal').on 'click', '.channels input[type="checkbox"]', ()->
      $('#check_all').prop('checked', $('.channels input[type="checkbox"]:checked').length == $('.channels input[type="checkbox"]').length)

    #反选
    $('#setChannelModal').on 'click', '#anti_all', ()->
      $('.channels input[type="checkbox"]').each(()->
        $(this).prop('checked', !this.checked)
      )

    $('#setChannelModal').on 'click', '.submit_channel', (e)->
      e.preventDefault()
      if $('.channels input[type="checkbox"]:checked').length < 1
        alert('请选择一个渠道')
      else
        ids = $('.channels input[type="checkbox"]:checked').map(()->
                return $(this).val()
              ).toArray()

        $('.ui-selected').each(()->
          $(this).data('channel-ids', ids)
        )
        $('#setChannelModal input[type="checkbox"]').prop('checked', false)
        $('#setChannelModal').modal('hide')

    #提交选座图
    $('.submit_seats').on 'click', ()->
      if $('ul.seats span').length < 1
        return false
      else if $('.blank').length > 0
        alert('还有座位没有设置状态')
        $('.blank').addClass('no-status')
      else
        get_seats_info()
