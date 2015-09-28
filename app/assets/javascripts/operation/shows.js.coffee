set_pie_cake = (unpaid_count, left_count, sold_count, area_name, tickets_count) ->
  option =
    title:
      text: area_name + "(共" + tickets_count + "张)"
      x: "center"
    tooltip:
      show: true
    calculable: false
    series: [
      type: "pie"
      radius: "40%"
      # 标签文本和引导线
      itemStyle:
        normal:
          label:
            textStyle:
              fontWeight: "bolder"
              fontSize: 16
          labelLine: length: 0
      data: [
        {value: sold_count, name: "售出"}
        {value: unpaid_count, name: "未支付"}
        {value: left_count, name: "剩余"}
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

# for hash merge, need to move to comman place
merge = (xs...) ->
  if xs?.length > 0
    tap {}, (m) -> m[k] = v for k, v of x for x in xs

tap = (o, fn) -> fn(o); o

get_seats_info = (target)->
  show_id = $('#show_id').val()
  area_id = $('#area_id').val()
  area_name = $('#area_name').val()
  sort_by = $('#area_sort_by').val()
  data = { seats: {}, total: '', sort_by: '' }

  # set seats
  $('ul.seats li.row_li').each(()->
    $li = $(this)
    $li.children().each(()->
      status = $(this).data('status')
      if status != undefined && status != ''
        row_key = $(this).data('row-id')
        col_key = $(this).data('column-id')
        seat_no = "#{row_key}排#{col_key}座"
        value = {"#{col_key}": { status: status, price: $(this).data('seat-price'), channels: $(this).data('channel-ids'), seat_no: seat_no } }
        # 组成 hash
        data['seats'][row_key] = if data['seats'][row_key] != undefined
          merge data['seats'][row_key], value
        else
          value
    )
  )
  # set max row and column
  row_size = $('#row_size').val()
  column_size = $('#column_size').val()
  data['total'] = "#{row_size}|#{column_size}"

  # set sort_by
  data['sort_by'] = sort_by

  pop_content('数据保存中,请稍等......')
  $.post("/operation/shows/#{show_id}/update_seats_info", {area_id: area_id, seats_info: JSON.stringify(data), area_name: area_name}, (data)->
    if data.success
      if target == 'reload'
        location.reload()
      else
        location.href = "/operation/shows/#{show_id}/edit"
  )

insert_obj = (obj)->
  node = window.getSelection().anchorNode
  if node && node.nodeType == 3
    $(node).after(obj)
  else
    $('.qeditor_preview').append(obj)

init_editor = ()->
  toolbar = $('#show_description').parent().find('.qeditor_toolbar')
  editor = $(".qeditor_preview")

  video = $("<a href='#' class='qe-video'><span class='fa fa-video-camera'></span><input id='video_uploader' type='file' name='file' accept='audio/*'/></a>")
  video.on 'click', ()->
    $('#video_uploader').fileupload
      url: "/operation/shows/upload"
      dataType: "json"
      add: (e, data) ->
        types = /(\.|\/)(mp4)$/i
        file = data.files[0]
        if types.test(file.type) || types.test(file.name)
          data.submit()
          $('.qeditor_preview').append($('<div id="progress" style="width: 300px;"><div class="bar" style="width: 0%;"></div></div>'))
        else
          alert("#{file.name}不是mp4视频文件")
      progressAll: (e, data) ->
        progressNo = parseInt(data.loaded / data.total * 100, 10)
        $('#progress .bar').css('width', progressNo + '%')
      submit: (e, data) ->
        data.formData = {
          file: $('#video_uploader').val(),
          file_type: 'video'
        }
      done: (e, data) ->
        $video = "<p><video controls><source src='#{data.result.file_path}' /></video><br /></p>"
        insert_obj($video)
        $('#progress').hide()
        editor.change()

  image = $("<a href='#' class='qe-image'><span class='fa fa-picture-o'></span><input id='image_uploader' type='file' name='file' accept='image/*'/></a>")
  image.on 'click', ()->
    $('#image_uploader').fileupload
      url: "/operation/shows/upload"
      dataType: "json"
      add: (e, data) ->
        types = /(\.|\/)(gif|jpe?g|png)$/i
        file = data.files[0]
        if types.test(file.type) || types.test(file.name)
          data.submit()
          $('.qeditor_preview').append($('<div id="progress" style="width: 300px;"><div class="bar" style="width: 0%;"></div></div>'))
        else
          alert("#{file.name}不是gif, jpeg, 或png图像文件")
      progress: (e, data) ->
        progressNo = parseInt(data.loaded / data.total * 100, 10)
        $('#progress .bar').css('width', progressNo + '%')
      submit: (e, data) ->
        data.formData = {
          file: $('#image_uploader').val(),
          file_type: 'image'
        }
      done: (e, data) ->
        $img = "<p><img src='#{data.result.file_path}' /><br /></p>"
        insert_obj($img)
        $('#progress').hide()
        editor.change()

  toolbar.append(video, image)

pop_content = (content)->
  $('#pop-modal p').text(content)
  $('#pop-modal').modal('show')

#设置热区
set_area = (event_id)->
  coordinate_hash = $("##{event_id} .coordinate_hash").data("coordinate-data")
  color_ids = $("##{event_id} .coordinate_hash").data("color-ids")
  area_id_name = $("##{event_id} .coordinate_hash").data("area-id-name")
  colors_array = Object.keys(coordinate_hash)
  $("##{event_id} .stadium_pic_map area").remove()
  for color in colors_array
    return false if color == "width"
    return false if color == "height"
    binding_color=area_id=area_name = ""
    if color_ids.length > 0
      for color_id in color_ids
        if color_id[0] == color
          binding_color = color_id[0]
          area_id = color_id[1]
          area_name = area_id_name[area_id]
    coordinate_string = coordinate_hash[color]
    $("##{event_id} .stadium_pic_map").append("<area id=\"#{color}_#{event_id}\" shape=\"poly\" coords=\"#{coordinate_string}\" href =\"#\" color=\"#{binding_color}\" area_id=\"#{area_id}\" area_name=\"#{area_name}\"   />")

#画出区域
draw_area_with_coords = (coords, context, fill_style="rgba(0, 0, 0, 0.7)")->
  context.beginPath()
  x = y = 0
  for coordinate, coordinate_index in coords
    if coordinate_index % 2 == 0
      x = coordinate
    if coordinate_index % 2 == 1
      y = coordinate
      if coordinate_index == 1
        context.moveTo(x, y)
      else
        context.lineTo(x, y)
  context.fillStyle = fill_style
  context.fill()
  context.closePath()

#画出所有的区域
draw_areas = (context, selected_area, no_selected_area)->
  if selected_area.length > 0
    for coords in selected_area
      coords = coords.split(",")
      draw_area_with_coords(coords, context, "rgba(255, 255, 255, 0.4)")
  if no_selected_area.length > 0
    for coords in no_selected_area
      coords = coords.split(",")
      draw_area_with_coords(coords, context, "rgba(0, 0, 0, 0.4)")

#拿到坐标
get_coordinates = (show_id, event_id)->
  $.get("/operation/shows/#{show_id}/get_coordinates", {event_id: event_id}, (data_hash)->
    result = data_hash.coords
    values = $.map(result, (v)->  return v)
    $("##{event_id} .coordinate_hash").data('area-coordinates', data_hash.area_coordinates)
    select_areas = $("##{event_id} .coordinate_hash").data('area-coordinates') || []
    no_selected_areas = values[0..-3].filter((el)-> return select_areas.indexOf(el) < 0)
    $("##{event_id} .coordinate_hash").data('no-bind-area-coordinates', no_selected_areas)
    $("##{event_id} .coordinate_hash").data('color-ids', data_hash.color_ids)
    $("##{event_id} .coordinate_hash").data('area-id-name', data_hash.area_id_name)
    $("##{event_id} .coordinate_hash").data('coordinate-data', result).data('width', result['width']).data('height', result['height'])
    $("##{event_id} .stadium_pic_div, ##{event_id} canvas, ##{event_id} img").width(result['width']).height(result['height'])
    $("##{event_id} .stadium_pic_div").css('background-size', "#{result['width']}px #{result['height']}px")

    canvas = $("##{event_id} canvas")[0]
    canvas.width = canvas.parentNode.clientWidth
    canvas.height = canvas.parentNode.clientHeight
    set_area(event_id)
    draw_areas(canvas.getContext("2d"), $("##{event_id} .coordinate_hash").data('area-coordinates'), $("##{event_id} .coordinate_hash").data("no-bind-area-coordinates"))
  )
$ ->
  $('.change_show_area_data').hide()

  # 修改按钮
  $('.editable_toggle').on 'click', ->
    $(this).siblings().eq(0).show()
    $(this).parent().siblings().children().attr('disabled', false)
    $(this).hide()

  $(document).ajaxComplete ->
    $('.change_show_area_data').hide()
    $('.editable_toggle').parent().siblings().children().attr('disabled', true)
    $('.editable_toggle').on 'click', ->
      $(this).siblings().eq(0).show()
      $(this).parent().siblings().children().attr('disabled', false)
      $(this).hide()

  $('.image-uploader').change ->
    readURL this

  if $('#show_description').length > 0
    $('#show_description').qeditor({})
    init_editor()
#show show
  if $(".show_show").length > 0
    $("#pie_cake div").each(() ->
      left_count = $(this).attr("left_count")
      sold_count = $(this).attr("sold_count")
      unpaid_count = $(this).attr("unpaid_count")
      area_name = $(this).attr("id")
      tickets_count = $(this).attr("total_tickets")
      if tickets_count > 0
        $(this).width(325).height(325)
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
      stadium_select = $("#show_stadium_select").val()
      if stadium_select == "" or stadium_select == null or stadium_select == "所选城市暂无场馆"
        alert('场馆不能为空，请重新选择')
      else if $("#show_city_select").val() == ""
        alert('城市不能为空，请重新选择')
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

  if $('.event_list').length > 0
    show_id = $("#show_id").val()
    $('.addEventModal #show_time, .editEventModal #show_time').datetimepicker()
    if location.hash
      $("#event_tabs a[href='" + location.hash + "']").tab('show')
      get_coordinates(show_id, location.hash.substr(1))

    $("#event_tabs a").on "click", (e) ->
      e.preventDefault()
      $(this).tab('show')
      get_coordinates(show_id, $(this).attr("href").substr(1))

    $("ul.nav-tabs > li > a").on "shown.bs.tab", (e) ->
      id = $(e.target).attr("href").substr(1)
      location.hash = id

    #修改场次
    $('.edit_event').on 'click', ()->
      $('#event_id').val($(this).data('id'))
      $('.editEventModal').modal('show')

    #删除场次
    $('.event_list li .close').on 'click', ()->
      if confirm('确定要删除该场次吗?')
        $.post("/operation/shows/#{show_id}/del_event", {_method: 'delete', event_id: $(this).data('id')}, (data)->
          if data.success
            location.reload()
        )

    #上传场馆图
    $('.upload_stadium_map').on 'click', ()->
      event_id = $(this).data('id')
      $(this).find('input').fileupload
        url: "/operation/shows/#{show_id}/upload_map"
        dataType: 'json'
        formData: {event_id: event_id}
        done: (e, data)->
          if $("##{event_id} .stadium_map_preview img").length > 0
            $("##{event_id} .stadium_map_preview img").attr("src", data.result.file_path)
          else
            $("##{event_id} .stadium_map_preview").append("<img src='#{data.result.file_path}' width='500'/>")

    #更新坐标图
    $('.upload_coordinate_map').on 'click', ()->
      event_id = $(this).data('id')
      $(this).find('input').fileupload
        url: "/operation/shows/#{show_id}/upload_map"
        dataType: 'json'
        formData: {event_id: event_id}
        add: (e, data) ->
          types = /(\.|\/)(bmp)$/i
          file = data.files[0]
          if types.test(file.type) || types.test(file.name)
            data.submit()
          else
            alert("图片必须是bmp格式")
        done: (e, data)->
          location.reload()

    #绑定区域
    $('.event_list').on 'click', '.stadium_pic_map area', (el)->
      coords_hash = $(this).parents('.stadium_map_preview').find('.coordinate_hash').data('coordinate-data')
      event_id = $(this).parents('.stadium_map_preview').data('id')
      context = $("##{event_id} canvas")[0].getContext('2d')
      el.preventDefault()
      color = $(this).attr('id').substr(0, 6)
      #区域已绑定
      if $(this).attr('area_id')
        name = prompt('修改区域名称', $(this).attr('area_name'))
        if name && name.length > 0
          $.post("/operation/shows/#{show_id}/update_area_data", {area_id: $(this).attr('area_id'), area_name: name}, (data)->
            $(".#{event_id}_areas tbody").html(data)
            $("##{color}_#{event_id}").attr("area_name", name)
          )
      else
        name = prompt('请输入区域名称')
        if name && name.length > 0
          area_coordinates = coords_hash[color]
          $.post("/operation/shows/#{show_id}/new_area", {event_id: event_id, area_name: name, color: color, coordinates: area_coordinates}, (data)->
            $(".#{event_id}_areas tbody").html(data)
            #向area热区添加属性
            $("##{color}_#{event_id}").attr({
              area_id: $(".#{event_id}_areas tbody tr").last().attr("area_id"),
              color: $(".#{event_id}_areas tbody tr").last().attr("color"),
              area_name: $(".#{event_id}_areas tbody tr").last().attr("area_name")
            })
            #添加已经绑定的区域的坐标
            selected_area = $("##{event_id} .coordinate_hash").data("area-coordinates")
            no_selected_area = $("##{event_id} .coordinate_hash").data("no-bind-area-coordinates")
            selected_area.push(area_coordinates)
            no_selected_area.splice(no_selected_area.indexOf(area_coordinates),1)
            context.clearRect(0, 0, coords_hash['width'], coords_hash['height'])
            draw_areas(context, selected_area, no_selected_area)
          )
        else
          alert('区域名不能为空')

    #增加区域
    $('.add_area').on 'click', ()->
      event_id = $(this).data('id')
      name = prompt('请输入区域名称')
      if name.length > 0
        $.post("/operation/shows/#{show_id}/new_area", {area_name: name, event_id: event_id}, (data)->
          $(".#{event_id}_areas tbody").html(data)
        )
      else
        alert('区域名不能为空')

    #删除区域
    $('.areas').on 'click', '.del_area', ()->
      if confirm('确定要删除该区域吗')
        event_id = $(this).parents('table').data('id')
        area_id = $(this).parent().data('id')
        if area_id
          $.post("/operation/shows/#{show_id}/del_area", {area_id: area_id, _method: 'delete'}, (data)->
            location.reload()
          )

    #修改区域
    $('.areas').on "click", ".change_show_area_data", () ->
      event_id = $(this).parents('table').data('id')
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
          $(".#{event_id}_areas tbody").html(data)
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
        event_id = $(this).parents('table').data('id')
        ids = $('.channels input[type="checkbox"]:checked').map(()->
                return $(this).val()
              ).toArray()
        $.post("/operation/shows/#{show_id}/set_area_channels", {area_id: $('#area_id').val(), ids: ids}, (data)->
          $('#setChannelModal').modal('hide')
          $(".#{event_id}_areas tbody").html(data)
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
    $('ul.seats').selectable({
      filter: 'span',
      selected: (event, ui)->
        $('ul.seats li').removeClass('checked')
        $('.ui-selected').parent().addClass('checked')
    })

    $('ul.seats span').tooltip()

    column_size = $('#column_size').val()
    rest_width = $('ul.seats').width() - column_size * 24
    if rest_width > 0
      $('ul.seats').width(column_size * 24)
      $('.content').css('padding-left': rest_width/2 - 20)

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
          $('ul.seats').append '<li class=\'row_li row_' + (i + 1) + '\'></li>'
          j = 0
          while j < column_size
            $('li.row_' + (i + 1)).append '<span title=\'\' class=\'seat\' data-seat-no=\'\' data-row-id=\'' + (i + 1) + '\' data-column-id=\'' + (j + 1) + '\'></span>'
            j++
          i++
        $('ul.seats').selectable({
          filter: 'span',
          selected: (event, ui)->
            $('ul.seats li').removeClass('checked')
            $('.ui-selected').parent().addClass('checked')
        })
      get_seats_info('reload')

    #全选座位
    $('.check_all_seats').on 'click', ()->
      $('.seat').addClass('ui-selected')

    #设置座位状态
    $('.set_avaliable').on 'click', ()->
      $('.ui-selected').data('status', 'avaliable').addClass('avaliable').removeClass('locked unused ui-selected')

    $('.set_locked').on 'click', ()->
      $('.ui-selected').data('status', 'locked').addClass('locked').removeClass('avaliable unused ui-selected')

    $('.set_unused').on 'click', ()->
      $('.ui-selected').data('status', 'unused').addClass('unused').removeClass('locked avaliable ui-selected')

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

    #全选渠道
    $('#setChannelModal').on 'click', '#check_all', ()->
      $('.channels input[type="checkbox"]').prop('checked', $(this).prop('checked'))

    $('#setChannelModal').on 'click', '.channels input[type="checkbox"]', ()->
      $('#check_all').prop('checked', $('.channels input[type="checkbox"]:checked').length == $('.channels input[type="checkbox"]').length)

    #反选渠道
    $('#setChannelModal').on 'click', '#anti_all', ()->
      $('.channels input[type="checkbox"]').each(()->
        $(this).prop('checked', !this.checked)
      )

    #提交渠道
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
      if $('ul.seats span.avaliable').length > 1
        result = 0
        $('ul.seats span.avaliable').each(()->
          if $(this).data('seat-price').length < 1
            alert('可选座位价格不能为空')
            result += 1
            return false
        )
        get_seats_info('redirect') if result == 0
      else
        get_seats_info('redirect')
