insert_obj = (obj)->
  node = window.getSelection().anchorNode
  if node && (node.nodeType == 1 || node.nodeType == 3)
    $(node).after(obj)
  else
    $('.qeditor_preview').append(obj)

init_editor = ()->
  toolbar = $('#boom_activity_description').parent().find('.qeditor_toolbar')
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
          $('.qeditor_preview').append($('<div id="progress" style="width: 300px;"><div class="bar" style="width: 0%;"></div></div>'))
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
  activity_id = $('#activity_id').val()
  if $('#boom_activity_description').length > 0
    $('#boom_activity_description').qeditor()
    init_editor()

  $(document).on 'change', '.activities_filter', ->
    $('#activities_form').submit()

  # 标签
  all_tags = $("div#operation_activity_tags_data").data("data")
  $('#operation_activity_tags').tagit
    allowSpaces: true
    autocomplete: { delay: 0, minLength: 0, source: all_tags }
    showAutocompleteOnFocus: true

  # 艺人
  all_collaborators = $("div#operation_activity_collaborators_data").data("data")
  $('#operation_activity_collaborators').tagit
    allowSpaces: true
    autocomplete: { delay: 0, minLength: 0, source: all_collaborators }
    showAutocompleteOnFocus: true
  
  #上传海报
  $('.activity_cover_uploader').fileupload
    url: "/boombox/operation/activities/#{activity_id}/upload_cover"
    dataType: "json"
    done: (e, data) ->
      if data.result.success
        $('.cover_preview img').attr('src', data.result.cover_path)

  $('#boom_activity_cover').change ->
    readURL this, $('.cover_preview')

