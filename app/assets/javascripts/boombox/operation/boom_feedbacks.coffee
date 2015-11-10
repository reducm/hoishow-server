$ ->
  $(".boom_feedback_float").on "click", () ->
    $("#boom_fb_content ").text($(this).text())
    $("#boom_feedback_pop_wrap").modal('show')
