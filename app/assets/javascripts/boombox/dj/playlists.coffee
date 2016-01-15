$ ->
  $(document).on 'change', '.playlists_filter', ->
    $('#playlists_form').submit()

  if sessionStorage.getItem('show_search_tab') == "t"
    $("#playlist_manage_tab a[href='#playlist_search_tracks']").tab("show")
    sessionStorage.setItem('show_search_tab', 'f')

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

  #添加音乐 
  $("#playlist_search_tracks").on "click", ".add_track_to_playlist", (e) ->
    e.preventDefault()
    track_id = $(this).data("track-id")
    playlist_id = $("#playlist_id").val()
    pop_btn = $(this)
    if track_id && playlist_id
      $.ajax(
        url: "/boombox/dj/playlists/#{playlist_id}/add_track"
        method: 'POST'
        data:
          track_id: track_id
        success: (data, text, xhr) ->
          $.notify('添加音乐成功',
            globalPosition: 'top center'
            className: 'success'
          )
      )

  #移除音乐 
  $("#playlist_tracks").on "click", ".remove_track_to_playlist", (e) ->
    e.preventDefault()
    sessionStorage.setItem('show_search_tab', 'f')
    track_id = $(this).data("track-id")
    playlist_id = $("#playlist_id").val()
    if track_id && playlist_id
      $.ajax(
        url: "/boombox/dj/playlists/#{playlist_id}/remove_track"
        method: 'POST'
        data:
          track_id: track_id
        success: (data, text, xhr) ->
          $.notify('移除音乐成功',
            globalPosition: 'top center'
            className: 'success'
          )
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

  $("#new-playlist-submit").on "click", (e) ->
    e.preventDefault()
    $("#boom_tag_ids").val($('select#tags').val())
    # 新建 playlist 后，应跳转至“管理音乐”页面，并在“搜索添加”的 tab 下
    sessionStorage.setItem('show_search_tab', 't')
    $("form").submit()
