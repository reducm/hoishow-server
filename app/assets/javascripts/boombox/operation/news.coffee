insert_obj = (obj)->
  node = window.getSelection().anchorNode
  if node && (node.nodeType == 1 || node.nodeType == 3) && $('.qeditor_preview').find(node).length > 0
    $(node).after(obj)
  else
    $('.qeditor_preview').append(obj)

init_editor = ()->
  toolbar = $('#news_description').parent().find('.qeditor_toolbar')
  editor = $(".qeditor_preview")

  video = $("<a href='#' class='qe-video'><span class='fa fa-video-camera'></span></a>")
  video.on 'click', ()->
    $('#videoModal').modal('show')
    $('.add_video').on 'click', (e)->
      e.preventDefault()
      url = $('#inputUrl').val()
      title = $('#inputTitle').val()
      vid = url.split('id_')[1].split('.')[0]
      $video = $("<p class='video' data-title='#{title}' data-url='#{url}'><iframe src='http://player.youku.com/embed/#{vid}' frameborder=0 allowfullscreen></iframe><br /></p>")
      insert_obj($video)
      editor.change()
      $('#videoModal').modal('hide')

  image = $("<a href='#' class='qe-image'><span class='fa fa-picture-o'></span><input id='image_uploader' type='file' name='file' accept='image/*'/></a>")
  image.on 'click', ()->
    $('#image_uploader').fileupload
      url: "/boombox/operation/activities/upload_image"
      dataType: "json"
      add: (e, data) ->
        types = /(\.|\/)(gif|jpe?g|png)$/i
        file = data.files[0]
        if types.test(file.type) || types.test(file.name)
          data.submit()
        else
          alert("#{file.name}不是gif, jpeg, 或png图像文件")
      submit: (e, data) ->
        data.formData = {
          file: $('#image_uploader').val()
        }
      done: (e, data) ->
        $img = "<p><img src='#{data.result.file_path}' /><br /></p>"
        insert_obj($img)
        editor.change()

  toolbar.append(video, image)
$ ->
  $(document).on "change", '#news_form .news_filter', ->
    $(this).submit()

  if $('#news_description').length > 0
    $('#news_description').qeditor()
    init_editor()

    $('.news_cover_uploader').change ->
      readURL this, $('.cover_preview')
