click_seat = (show_id, status, el)->
  location.href = "/api/v1/shows/#{show_id}/click_seat?show_name=#{$('#show_name').val()}&area_id=#{$('#area_id').val()}&area_name=#{$('#area_name').val()}&seat_id=#{$(el).data('id')}&seat_name=#{$(el).data('seat-name')}&price=#{$(el).data('seat-price')}&remark=#{$(el).data('remark')}&status=#{status}"

$ ->
  show_id = $("#show_id").val()

  $(".seats_box").on 'click', '.avaliable', ()->
    $(this).addClass('checked').removeClass('avaliable')
    click_seat(show_id, 'checked', this)

  $(".seats_box").on 'click', '.checked', ()->
    $(this).addClass('avaliable').removeClass('checked')
    click_seat(show_id, 'avaliable', this)