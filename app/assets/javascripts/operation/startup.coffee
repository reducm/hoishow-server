$ ->
  if $(".startup_list").length > 0
    $("label").remove()

    $("#fileuploader").fileupload({
      url: '/operation/startup',
      dataType: 'json',
      done: (e, data) ->
        location.reload()
    })