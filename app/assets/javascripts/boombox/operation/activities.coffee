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
    url = prompt('请输入第三方视频链接地址')
    vid = url.split('id_')[1].split('.')[0]
    $video = $("<p class='video'><iframe src='http://player.youku.com/embed/#{vid}' frameborder=0 allowfullscreen></iframe><br /></p>")
    insert_obj($video)
    editor.change()

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

  #如果当前playlist有标签的话就把标签id保存起来
  tag_ids_val = $("#activity_tag_ids").val()
  if tag_ids_val
    tag_ids = tag_ids_val.split(" ")
  else
    tag_ids = []

  collaborator_ids_val = $("#activity_collaborator_ids").val()
  if collaborator_ids_val
    collaborator_ids = collaborator_ids_val.split(" ")
  else
    collaborator_ids = []

  #tag-filter
  $("#activity_tag_list").addClass('selectpicker').attr('data-live-search', true).attr('data-width', '135px').selectpicker()

  #添加tag
  $("#activity_add_tag").on "click", (e) ->
    e.preventDefault()
    tag_name = $("#activity_tag_list option:selected").text()
    tag_id = $("#activity_tag_list option:selected").val()
    if tag_id in tag_ids
      alert("该标签已选，请不要重复添加")
    else
      $("<span>#{tag_name}</span>").addClass("btn btn-default").appendTo("#activity_delete_tag")
      $("<button data-tag-id='#{tag_id}'>删除</button>").addClass("btn btn-danger remove_tag").appendTo("#activity_delete_tag")
      tag_ids.push(tag_id)

  #删除tag
  $("#activity_delete_tag").on "click", ".remove_tag", (e) ->
    e.preventDefault()
    tag_id = $(this).data("tag-id")
    $(this).prev().remove()
    $(this).remove()
    tag_ids.splice(tag_ids.indexOf(tag_id.toString()),1)

  #collaborator相关，结构与tag一样
  $("#activity_collaborator_list").addClass('selectpicker').attr('data-live-search', true).attr('data-width', '135px').selectpicker()

  $("#activity_add_collaborator").on "click", (e) ->
    e.preventDefault()
    collaborator_name = $("#activity_collaborator_list option:selected").text()
    collaborator_id = $("#activity_collaborator_list option:selected").val()
    if collaborator_id in collaborator_ids
      alert("该艺人已选，请不要重复添加")
    else
      $("<span>#{collaborator_name}</span>").addClass("btn btn-default").appendTo("#activity_delete_collaborator")
      $("<button data-collaborator-id='#{collaborator_id}'>删除</button>").addClass("btn btn-danger remove_collaborator").appendTo("#activity_delete_collaborator")
      collaborator_ids.push(collaborator_id)

  $("#activity_delete_collaborator").on "click", ".remove_collaborator", (e) ->
    e.preventDefault()
    collaborator_id = $(this).data("collaborator-id")
    $(this).prev().remove()
    $(this).remove()
    collaborator_ids.splice(collaborator_ids.indexOf(collaborator_id.toString()),1)

  #上传海报
  $('.activity_cover_uploader').fileupload
    url: "/boombox/operation/activities/#{activity_id}/upload_cover"
    dataType: "json"
    done: (e, data) ->
      if data.result.success
        $('.cover_preview img').attr('src', data.result.cover_path)

  $('#boom_activity_cover').change ->
    readURL this, $('.cover_preview')

  #提交前将标签和艺人id数组组装成字符串，并传入hidden field
  $("#activity-submit").on "click", (e) ->
    tag_ids.join(",")
    collaborator_ids.join(",")
    $("#boom_tag_ids").val(tag_ids)
    $("#boom_collaborator_ids").val(collaborator_ids)
    $("form").submit()
