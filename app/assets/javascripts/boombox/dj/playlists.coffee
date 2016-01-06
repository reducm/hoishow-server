$ ->
  $(document).on 'change', '.playlists_filter', ->
    $('#playlists_form').submit()

  if sessionStorage.getItem('show_search_tab') == "t"
    $("#playlist_manage_tab a[href='#playlist_search_tracks']").tab("show")

  #按了搜索按钮
  $("#playlist_search_track_btn").on "click", (e) ->
    e.preventDefault()
    sessionStorage.setItem('show_search_tab', 't')
    $("#search_playlist_tracks_form").submit()

  #playlist_search_tracks换页
  $("#playlist_search_track_table .pagination a").on "click", (e) ->
    sessionStorage.setItem('show_search_tab', 't')
    
  #刷新playlist_track_list
  $("#playlist_track_list").on "click", (e) ->
    e.preventDefault()
    sessionStorage.setItem('show_search_tab', 'f')
    playlist_id = $("#playlist_id").val()
    location.href = "/boombox/dj/playlists/#{playlist_id}/manage_tracks"

  #添加音乐 
  $("#playlist_search_tracks").on "click", ".add_track_to_playlist", (e) ->
    e.preventDefault()
    track_id = $(this).data("track-id")
    playlist_id = $("#playlist_id").val()
    pop_btn = $(this)
    if track_id && playlist_id
      $.post("/boombox/dj/playlists/#{playlist_id}/add_track", { track_id: track_id}, (data)->
        if data.success
          pop_btn.text("已添加")
          pop_btn.addClass("btn-success")
      )

  #移除音乐 
  $("#playlist_tracks").on "click", ".remove_track_to_playlist", (e) ->
    e.preventDefault()
    sessionStorage.setItem('show_search_tab', 'f')
    track_id = $(this).data("track-id")
    playlist_id = $("#playlist_id").val()
    if track_id && playlist_id
      $.post("/boombox/dj/playlists/#{playlist_id}/remove_track", { track_id: track_id}, (data)->
        if data.success
          location.reload()
      )

  # 标签
  if $('div#dj_playlist_tags_already_added').length > 0
    data = $('div#dj_playlist_tags_already_added').data('data')
    $('select#tags').val(data).select2()
  else
    $('select#tags').select2()

  $('.playlist-cover-uploader').change ->
    readURL this, $("#playlist_cover_preview")

  # 上传图片后隐藏playlist_cover_preview
  $('input#boom_playlist_cover').on 'change', ->
    $('div#playlist_cover_preview').hide()

  #提交前将标签id数组组装成字符串，并传入hidden field
  $("#playlist-submit").on "click", (e) ->
    e.preventDefault()
    $("#boom_tag_ids").val($('select#tags').val())
    $("form").submit()
