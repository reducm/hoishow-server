$ ->
  $(document).on 'change', '.radios_filter', ->
    $('#radios_form').submit()

  if sessionStorage.getItem('show_search_tab') == "t"
    $("#radio_manage_tab a[href='#radio_search_tracks']").tab("show")

  #按了搜索按钮
  $("#radio_search_track_btn").on "click", (e) ->
    e.preventDefault()
    sessionStorage.setItem('show_search_tab', 't')
    $("#search_radio_tracks_form").submit()

  #radio_search_tracks换页
  $("#radio_search_track_table .pagination a").on "click", (e) ->
    sessionStorage.setItem('show_search_tab', 't')
    
  #刷新radio_track_list
  $("#radio_track_list").on "click", (e) ->
    e.preventDefault()
    sessionStorage.setItem('show_search_tab', 'f')
    radio_id = $("#radio_id").val()
    location.href = "/boombox/operation/radios/#{radio_id}/manage_tracks"

  #添加音乐 
  $("#radio_search_tracks").on "click", ".add_track_to_playlist", (e) ->
    e.preventDefault()
    track_id = $(this).data("track-id")
    radio_id = $("#radio_id").val()
    pop_btn = $(this)
    if track_id && radio_id
      $.post("/boombox/operation/radios/#{radio_id}/add_track", { track_id: track_id}, (data)->
        if data.success
          pop_btn.popover("show")
          setTimeout(()->
            pop_btn.popover("hide")
          ,1000)
      )

  #移除音乐 
  $("#radio_tracks").on "click", ".remove_track_to_playlist", (e) ->
    e.preventDefault()
    sessionStorage.setItem('show_search_tab', 'f')
    track_id = $(this).data("track-id")
    radio_id = $("#radio_id").val()
    if track_id && radio_id
      $.post("/boombox/operation/radios/#{radio_id}/remove_track", { track_id: track_id}, (data)->
        if data.success
          location.reload()
      )


  #如果当前电台有标签的话就把标签id保存起来
  tag_ids_val = $("#radio_tag_ids").val()
  if tag_ids_val
    tag_ids = tag_ids_val.split(" ")
  else
    tag_ids = []

  #tag-filter
  $("#radio_tag_list").addClass('selectpicker').attr('data-live-search', true).attr('data-width', '135px').selectpicker()

  #添加tag
  $("#radio_tag_list").on "change", (e) ->
    e.preventDefault()
    tag_name = $("#radio_tag_list option:selected").text()
    tag_id = $("#radio_tag_list option:selected").val()
    if tag_id in tag_ids
      alert("该标签已选，请不要重复添加")
    else
      $("<span>#{tag_name}</span>").addClass("btn btn-default").appendTo("#radio_delete_tag")
      $("<button data-tag-id='#{tag_id}'>删除</button>").addClass("btn btn-danger remove_tag").appendTo("#radio_delete_tag")
      tag_ids.push(tag_id)

  #删除tag
  $("#radio_delete_tag").on "click", ".remove_tag", (e) ->
    e.preventDefault()
    tag_id = $(this).data("tag-id")
    $(this).prev().remove()
    $(this).remove()
    tag_ids.splice(tag_ids.indexOf(tag_id.toString()),1)


  $('.radio-cover-uploader').change ->
    readURL this, $("#radio_cover_preview")

  #提交前将标签id数组组装成字符串，并传入hidden field
  $("#radio-submit").on "click", (e) ->
    e.preventDefault()
    tag_ids.join(",")
    $("#boom_tag_ids").val(tag_ids)
    $("form").submit()
