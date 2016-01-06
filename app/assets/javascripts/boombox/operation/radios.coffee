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
  all_tags = $("div#operation_radio_tags_data").data("data")
  $('#operation_radio_tags').tagit
    allowSpaces: true
    autocomplete: { delay: 0, minLength: 0, source: all_tags }
    showAutocompleteOnFocus: true

  $('.radio-cover-uploader').change ->
    readURL this, $("#radio_cover_preview")

