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

  # 标签
  if $('div#operation_radio_tags_already_added').length > 0
    data = $('div#operation_radio_tags_already_added').data('data')
    $('select#tags').val(data).select2()
  else
    $('select#tags').select2()

  $('.radio-cover-uploader').change ->
    readURL this, $("#radio_cover_preview")

  #提交前将标签id数组组装成字符串，并传入hidden field
  $("#radio-submit").on "click", (e) ->
    e.preventDefault()
    $("#boom_tag_ids").val($('select#tags').val())
    $("form").submit()
