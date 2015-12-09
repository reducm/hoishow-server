#画出区域
draw_area_with_coords = (coords, context, fill_style="rgba(0, 0, 0, 0.5)")->
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


#设置热区
set_area = ()->
  areas_data = $("#show_area_data").data("areas-data")
  for area_data in areas_data
    coordinate_string = area_data[0]
    area_id = area_data[1]
    area_name = area_data[3]
    $("#stadium_pic_map").append("<area shape=\"poly\" coords=\"#{coordinate_string}\" href =\"#\" area_id=\"#{area_id}\" left_seats=\"#{area_data[2]}\" area_name=#{area_name} />")

document.addEventListener "touchmove", ((e) ->
  e.preventDefault()
  return
),false


load_page = ()->

  canvas = $("#mobile_stadium_canvas")[0]
  if canvas
    set_area()
    canvas.width = canvas.parentNode.clientWidth
    canvas.height = canvas.parentNode.clientHeight
    context = canvas.getContext("2d")

    screen_width = window.innerWidth
    screen_height = window.innerHeight

    widthRatio = screen_width / canvas.width
    heightRatio = screen_height / canvas.height

    minScale = Math.min(widthRatio, heightRatio)

    $('#container').height( window.innerHeight)

    $("body").css("overflow", "hidden")

    myScroll = new IScroll '#container', {
      zoom: true
      scrollX: true
      zoomMin: minScale
      zoomStart: minScale
      click: true
      freeScroll: true
    }
    myScroll.zoom(minScale)

    areas_data = $("#show_area_data").data("invalid-areas")
    setTimeout(() ->
      for area_data in areas_data
        area_coordinate = area_data.split(",")
        draw_area_with_coords(area_coordinate, context)
        $("#stadium_pic_map").append("<area shape=\"poly\" coords=\"#{area_coordinate}\" href =\"#\" left_seats=\"0\" />")

      $("#stadium_pic_map area").each((index, element)->
          $(element).on "click", (e)->
            show_id = $("#show_area_data").data("show-id")
            area_id = $(element).attr("area_id")
            area_name = $(element).attr("area_name")
            left_seats = $(element).attr("left_seats")
            if left_seats == "0"
              $("#areas_map_pop_wrap").modal('show')
              return false
            else
              location.href = "/seats_map?show_id=#{show_id}&area_id=#{area_id}&area_name=#{area_name}"
      )
    , 1000)

window.onload = () ->
  $('#container').show()
  load_page()
  return
