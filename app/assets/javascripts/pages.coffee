$ ->
  set_width = (n) ->
    old_count = parseInt($("#city_count_1").text())
    width = parseInt( $("#city_1").width() )
    count = parseInt($("#city_count_#{n}").text())
    $("#city_#{n}").width((count / old_count) * width)
    width = $("#city_#{n}").width()
    old_count = count

  set_width(i) for i in [1..10]

  $("#showdesc").click ->
    $(".description").slideToggle("600")

  if $('.page_index').length > 0
    $(".page_index").onepage_scroll({
      sectionContainer: "section"
      easing: "ease"
      keyboard: true
      direction: "vertical"
    })

  if $(".shareconcert").length > 0
    $(".shareconcert").fullpage({
      verticalCentered: false
      afterLoad: (anchorLink, index) ->
        if index == 2
          $(".top").show()
          $(".detailrank").show()
          $('.toprank').show()
          $('.allrank').hide()
    })

  $('.detailrank').click ->
    $('#top').slideUp()
    $('.detailrank').hide()
    $('.toprank').hide()
    $('.allrank').show()
    all_set_width = (n) ->
      old_count = parseInt($("#all_city_count_1").text())
      width = parseInt( $("#all_city_1").width() )
      count = parseInt($("#all_city_count_#{n}").text())
      $("#all_city_#{n}").width((count / old_count) * width)
      width = $("#all_city_#{n}").width()
      old_count = count

    all_set_width(i) for i in [1..10]


  $(".doubledown i").click ->
    $.fn.fullpage.moveSectionDown()
