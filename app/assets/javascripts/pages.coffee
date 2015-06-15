$ ->
  width = parseInt( $("#city_1").width() )
  old_count = parseInt($("#city_count_1").text())
  set_width = (n) ->
    count = parseInt($("#city_count_#{n}").text())
    $("#city_#{n}").width((count/old_count)*width)
    width = $("#city_#{n}").width()
    old_count = count

  set_width(i) for i in [1..10]


  $(".page_index").onepage_scroll({
    sectionContainer: "img"
    easing: "ease"
    animationTime: 1000
    pagination: true
    updateURL: false
    keyboard: true
    loop: true
  })
