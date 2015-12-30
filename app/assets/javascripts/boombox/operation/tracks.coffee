$ ->
  $(document).on 'change', '.tracks_filter', ->
    $('#tracks_form').submit()

  # 艺术家标签化
  if $('div#operation_artist_names').length > 0
    $('#operation_track_artists').tagit
      allowSpaces: true
      availableTags: $('div#operation_artist_names').data('data')
  else
    $('#operation_track_artists').tagit
      allowSpaces: true

  # 标签
  if $('div#operation_track_tags_already_added').length > 0
    data = $('div#operation_track_tags_already_added').data('data')
    $('select#tags').val(data).select2()
  else
    $('select#tags').select2()

  #播放音频
  $(".audio_name").on "click", (e) ->
    e.preventDefault()
    a = $(this).find("audio")
    if a.length == 1
      audio = a[0]
      if audio.paused
        $(this).removeClass("glyphicon-play")
        $(this).addClass("glyphicon-pause")
        audio.play()
      else
        $(this).removeClass("glyphicon-pause")
        $(this).addClass("glyphicon-play")
        audio.pause()

  $('.track-cover-uploader').change ->
    readURL this, $("#track_cover_preview")

  $('.track-file-uploader').change ->
    if this.files[0]
      obj_url = window.URL.createObjectURL(this.files[0])
      $("#track-file-pre").attr("src", obj_url).attr("controls", "controls")

#1.提交前将标签id数组组装成字符串，并传入hidden field
#2.获取音乐的duration
  $("#track-submit").on "click", (e) ->
    #1
    $("#boom_tag_ids").val($('select#tags').val())
    #2
    duration = $("#track-file-pre")[0].duration
    if duration
      $("#boom_track_duration").attr("value", duration)
    $("form").submit()
