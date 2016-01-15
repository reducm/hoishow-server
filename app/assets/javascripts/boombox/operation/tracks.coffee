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
    if this.files[0]
      ext = '.' + $(this).val().split('.').pop()
      if $.inArray(ext, [".jpg", ".jpeg", ".gif", ".png"]) == -1
        $(this).val('')
        alert '请上传.jpg, .jpeg, .gif, .png格式图片'
      else
        readURL this, $("#track_cover_preview")

  $('.progress').hide()
  $('#upload_status').hide()
  # 选择文件后显示文件信息
  $('.track-file-uploader').change ->
    if this.files[0]
      ext = '.' + $('#upyun_upload').val().split('.').pop()
      if ext != '.mp3'
        $('.track-file-uploader').val('')
        alert '请上传mp3格式音乐'
      else
        $('#upyun_upload').hide()
        obj_url = window.URL.createObjectURL(this.files[0])
        $("#track-file-pre").attr("src", obj_url).attr("controls", "controls")

        # 直传又拍云
        config =
          bucket: 'boombox-file'
          expiration: parseInt((new Date().getTime() + 3600000) / 1000),
          form_api_secret: 's83au5+hc0rd545EsOXcb9Io/8g='
        instance = new Sand(config)
        path = '/track_upload/' + parseInt(((new Date).getTime() + 3600000) / 1000) + ext
        $('.progress').show()
        $('.progress-bar').attr("aria-valuenow", 0).css('width', 0 + '%').text(0 + '%')
        $('#upload_status').removeClass('alert-success').addClass('alert-warning').show().text('正在初始化')
        $('#track-submit').addClass('disabled').val('正在上传')
        instance.upload(path, '#upyun_upload')

        document.addEventListener 'uploaded', (e) ->
          $("#boom_track_file").attr("value", path)
    return
  #获取音乐的duration
  $("#track-submit").on "click", (e) ->
    e.preventDefault()
    if $('#boom_track_file').val() == ""
      alert '请上传音乐'
      return
    else if $('#boom_track_name').val() == ""
      alert '请填写标题'
      return
    else
    duration = $("#track-file-pre")[0].duration
    if duration
      $("#boom_track_duration").attr("value", duration)
    $('#upyun_upload').remove()
    $("form").submit()
