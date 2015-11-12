$ ->
  #如果当前playlist有标签的话就把标签id保存起来
  tag_ids_val = $("#playlist_tag_ids").val()
  if tag_ids_val
    tag_ids = tag_ids_val.split(" ")
  else
    tag_ids = []

  #tag-filter
  $("#playlist_tag_list").addClass('selectpicker').attr('data-live-search', true).attr('data-width', '135px').selectpicker()

  #添加tag
  $("#playlist_add_tag").on "click", (e) ->
    e.preventDefault()
    tag_name = $("#playlist_tag_list option:selected").text()
    tag_id = $("#playlist_tag_list option:selected").val()
    if tag_id in tag_ids
      alert("该标签已选，请不要重复添加")
    else
      $("<span>#{tag_name}</span>").addClass("btn btn-default").appendTo("#playlist_delete_tag")
      $("<button data-tag-id='#{tag_id}'>删除</button>").addClass("btn btn-danger remove_tag").appendTo("#playlist_delete_tag")
      tag_ids.push(tag_id)

  #删除tag
  $("#playlist_delete_tag").on "click", ".remove_tag", (e) ->
    e.preventDefault()
    tag_id = $(this).data("tag-id")
    $(this).prev().remove()
    $(this).remove()
    tag_ids.splice(tag_ids.indexOf(tag_id.toString()),1)


  $('.playlist-cover-uploader').change ->
    $("#playlist_cover_url").hide()
    readURL this

  #提交前将标签id数组组装成字符串，并传入hidden field
  $("#playlist-submit").on "click", (e) ->
    tag_ids.join(",")
    $("#boom_tag_ids").val(tag_ids)
    $("form").submit()
