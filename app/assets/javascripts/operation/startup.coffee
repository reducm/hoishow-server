$ ->
  if $(".startup_list").length > 0
    $("label").remove()

    $('#fileuploader').fileupload
      url: '/operation/startup'
      dataType: "json"
      add: (e, data) ->
        types = /(\.|\/)(gif|jpe?g|png)$/i
        file = data.files[0]
        if types.test(file.type) || types.test(file.name)
          $('#fileuploader').appendTo(data.context)
          data.submit()
        else
          alert("#{file.name}不是gif, jpeg, 或png图像文件")
      progress: (e, data) ->
        if data.context
          progress = parseInt(data.loaded / data.total * 100, 10)
          data.context.find('.bar').css('width', progress + '%')
      done: (e, data) ->
        location.reload()
