$ ->
  show_id = $("#show_id").val()

  $(".seats_box .avaliable").on 'click', ()->
    $(this).addClass('checked').removeClass('avaliable')
    $.get("/api/v1/shows/#{show_id}/click_seat", {show_name: $("#show_name").val(), area_id: $('#area_id').val(), area_name: $('#area_name').val(), row_id: $(this).data('row-id'), column_id: $(this).data('column-id'), seat_name: $(this).data('seat-name'), price: $(this).data('seat-price'), remark: $(this).data('remark')})