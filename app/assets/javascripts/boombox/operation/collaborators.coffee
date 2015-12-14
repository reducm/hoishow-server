$ ->
  $(document).on 'change', '.collaborators_filter', ->
    $('#collaborators_form').submit()

  # 旧昵称
  original_nickname = $('#collaborator_nickname').val()

  #如果当前playlist有标签的话就把标签id保存起来
  tag_ids_val = $("#collaborator_tag_ids").val()
  if tag_ids_val
    tag_ids = tag_ids_val.split(" ")
  else
    tag_ids = []

  #tag-filter
  $("#collaborator_tag_list").addClass('selectpicker').attr('data-live-search', true).attr('data-width', '135px').selectpicker()

  #添加tag
  $("#collaborator_add_tag").on "click", (e) ->
    e.preventDefault()
    tag_name = $("#collaborator_tag_list option:selected").text()
    tag_id = $("#collaborator_tag_list option:selected").val()
    if tag_id in tag_ids
      alert("该标签已选，请不要重复添加")
    else
      $("<span>#{tag_name}</span>").addClass("btn btn-default").appendTo("#collaborator_delete_tag")
      $("<button data-tag-id='#{tag_id}'>删除</button>").addClass("btn btn-danger remove_tag").appendTo("#collaborator_delete_tag")
      tag_ids.push(tag_id)

  #删除tag
  $("#collaborator_delete_tag").on "click", ".remove_tag", (e) ->
    e.preventDefault()
    tag_id = $(this).data("tag-id")
    $(this).prev().remove()
    $(this).remove()
    tag_ids.splice(tag_ids.indexOf(tag_id.toString()),1)

  # 昵称有修改时
  $('#collaborator_edit_btn').on 'click', (e) ->
    e.preventDefault()
    #提交前将标签id数组组装成字符串，并传入hidden field
    tag_ids.join(",")
    $("#boom_tag_ids").val(tag_ids)
    #昵称相关
    if $('#collaborator_nickname').val() != original_nickname
      if confirm('昵称一个月内只能修改一次，确定修改吗？')
        $("#collaborator-dropzone").submit()
    else
      $("#collaborator-dropzone").submit()
