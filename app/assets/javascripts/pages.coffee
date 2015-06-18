$ ->
  width = parseInt( $("#city_1").width() )
  old_count = parseInt($("#city_count_1").text())
  set_width = (n) ->
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

  if $('.shareconcert').length > 0
    $('.shareconcert').onepage_scroll
      sectionContainer: '.page'
      pagination: 'false'
      beforeMove: (index) ->
        switch index
          when 1
           $(".top").show()
           $(".detailrank").show()
           $('.toprank').show()
           $('.allrank').hide()
        return

    $('.detailrank').click ->
      $('#top').slideUp()
      $('.detailrank').hide()
      $('.toprank').hide()
      $('.allrank').show()

