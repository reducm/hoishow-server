$ ->
  $(document).on 'change', '.playlists_filter', ->
    $('#playlists_form').submit()

  if sessionStorage.getItem('show_search_tab') == "t"
    $("#playlist_manage_tab a[href='#search_tracks']").tab("show")

  $("#search_track_btn").on "click", (e) ->
    e.preventDefault()
    sessionStorage.setItem('show_search_tab', 't')
    $("form").submit()

  $("#playlist_search_track_table .pagination a").on "click", () ->
    sessionStorage.setItem('show_search_tab', 't')
    
  #刷新playlist_track_list
  $("#playlist_track_list").on "click", (e) ->
    e.preventDefault()
    sessionStorage.setItem('show_search_tab', 'f')
    playlist_id = $("#playlist_id").val()
    location.href = "/boombox/dj/playlists/#{playlist_id}/manage_tracks"

  #添加音乐 
  $("#search_tracks").on "click", ".add_track_to_playlist", (e) ->
    e.preventDefault()
    track_id = $(this).data("track-id")
    playlist_id = $(this).data("playlist-id")
    pop_btn = $(this)
    if track_id && playlist_id
      $.post("/boombox/dj/playlists/#{playlist_id}/add_track", { track_id: track_id}, (data)->
        if data.success
          pop_btn.popover("show")
          setTimeout(()->
            pop_btn.popover("hide")
          ,1000)
      )

  #移除音乐 
  $("#playlist_tracks").on "click", ".remove_track_to_playlist", (e) ->
    e.preventDefault()
    sessionStorage.setItem('show_search_tab', 'f')
    track_id = $(this).data("track-id")
    playlist_id = $(this).data("playlist-id")
    if track_id && playlist_id
      $.post("/boombox/dj/playlists/#{playlist_id}/remove_track", { track_id: track_id}, (data)->
        if data.success
          location.reload()
      )


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
    readURL this, $("#playlist_cover_preview")

  #提交前将标签id数组组装成字符串，并传入hidden field
  $("#playlist-submit").on "click", (e) ->
    e.preventDefault()
    tag_ids.join(",")
    $("#boom_tag_ids").val(tag_ids)
    $("form").submit()

  #上传图片后隐藏playlist_cover_preview
  $('input#boom_playlist_cover').on 'change', ->
    $('div#playlist_cover_preview').hide()
