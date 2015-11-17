$ ->
  $(document).on 'change', '.boom_feedbacks_filter', ->
    $('#boom_feedbacks_form').submit()

  $(".boom_feedback_float").on "click", () ->
    $("#boom_fb_content").text($(this).text())
    $("#boom_feedback_pop_wrap").modal('show')
