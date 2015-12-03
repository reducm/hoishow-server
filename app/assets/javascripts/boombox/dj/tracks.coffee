$ ->
  #如果当前track有标签的话就把标签id保存起来
  track_tag_ids_val = $("#track_tag_ids").val()
  if track_tag_ids_val
    tag_ids = track_tag_ids_val.split(" ")
  else
    tag_ids = []

  #tag-filter
  $("#track_tag_list").addClass('selectpicker').attr('data-live-search', true).attr('data-width', '135px').selectpicker()

  #添加tag
  $("#track_add_tag").on "click", (e) ->
    e.preventDefault()
    tag_name = $("#track_tag_list option:selected").text()
    tag_id = $("#track_tag_list option:selected").val()
    if tag_id in tag_ids
      alert("该标签已选，请不要重复添加")
    else
      $("<span>#{tag_name}</span>").addClass("btn btn-default").appendTo("#track_delete_tag")
      $("<button data-tag-id='#{tag_id}'>删除</button>").addClass("btn btn-danger remove_tag").appendTo("#track_delete_tag")
      tag_ids.push(tag_id)

  #删除tag
  $("#track_delete_tag").on "click", ".remove_tag", (e) ->
    e.preventDefault()
    tag_id = $(this).data("tag-id")
    $(this).prev().remove()
    $(this).remove()
    tag_ids.splice(tag_ids.indexOf(tag_id.toString()),1)

  $('.track-cover-uploader').change ->
    $("#track_cover_url").hide()
    readURL this

  $('.track-file-uploader').change ->
    if this.files[0]
      reader = new FileReader
      reader.onload = (e) ->
        $("#track-file-pre").attr("src", e.target.result).attr("controls", "controls")
      reader.readAsDataURL this.files[0]
    return

#1.提交前将标签id数组组装成字符串，并传入hidden field
#2.获取音乐的duration
  $("#track-submit").on "click", (e) ->
    e.preventDefault()
    if $('.track-file-uploader').val() == ""
      alert '请上传音乐'
      return
    else if $('#boom_track_name').val() == ""
      alert '请填写标题'
      return
    else
      #1
      tag_ids.join(",")
      $("#boom_tag_ids").val(tag_ids)
      #2
      duration = $("#track-file-pre")[0].duration
      if duration
        $("#boom_track_duration").attr("value", duration)
      $("form").submit()
