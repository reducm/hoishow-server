$ ->
  $(document).on 'change', '.tracks_filter', ->
    $('#tracks_form').submit()

  # 艺术家标签化
  all_artists = $('div#operation_artist_names').data('data')
  $('#operation_track_artists').tagit
    allowSpaces: true
    autocomplete: { delay: 0, minLength: 0, source: all_artists }
    showAutocompleteOnFocus: true

  # 标签
  all_tags = $("div#operation_track_tags").data("all-tags")
  $('#operation_track_tags').tagit
    allowSpaces: true
    autocomplete: { delay: 0, minLength: 0, source: all_tags }
    showAutocompleteOnFocus: true

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
      reader = new FileReader
      reader.onload = (e) ->
        $("#track-file-pre").attr("src", e.target.result).attr("controls", "controls")
      reader.readAsDataURL this.files[0]
    return

#获取音乐的duration
  $("#track-submit").on "click", (e) ->
    duration = $("#track-file-pre")[0].duration
    if duration
      $("#boom_track_duration").attr("value", duration)
    $("form").submit()
