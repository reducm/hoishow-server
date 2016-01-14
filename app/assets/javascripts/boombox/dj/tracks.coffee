$ ->
  ####### 编辑页
  # 上传图片后隐藏默认占位图
  $('input#boom_track_cover').on 'change', ->
    $('div#track_cover_preview').hide()
    readURL this

  # 艺术家标签化
  $(document).ready ->
    if $('div#artist_names').length > 0
      $('#boom_track_artists').tagit
        allowSpaces: true
        availableTags: $('div#artist_names').data('data')
    else
      $('#boom_track_artists').tagit
        allowSpaces: true

  # 标签
  if $('div#tags_already_added').length > 0
    data = $('div#tags_already_added').data('data')
    $('select#tags').val(data).select2()
  else
    $('select#tags').select2()

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
        obj_url = window.URL.createObjectURL(this.files[0])
        $("#track-file-pre").attr("src", obj_url).attr("controls", "controls")

        name = this.files[0].name
        filename = name.replace(/\.[^/.]+$/, "")
        size = Math.round(this.files[0].size / 1024 / 1024 * 100) / 100
        $('#current_file').attr('data-url', 'true')
        $('#boom_track_name').val(filename)
        $('#track_filename').text("文件：" + name)
        $('#track_size').text("大小：" + size + " MB")

        # 直传又拍云
        config =
          bucket: 'boombox-file'
          expiration: parseInt((new Date().getTime() + 3600000) / 1000),
          form_api_secret: 's83au5+hc0rd545EsOXcb9Io/8g='
        instance = new Sand(config)
        path = '/track_upload/' + parseInt(((new Date).getTime() + 3600000) / 1000) + ext
        instance.upload(path, '#upyun_upload')

        document.addEventListener 'uploaded', (e) ->
          $("#boom_track_file").attr("value", path)
    return

  if $("#track-file-pre")[0]
    $("#track-file-pre")[0].addEventListener 'durationchange', ->
      #you can display the duration now
      duration = this.duration
      mins = Math.floor(duration / 60)
      secs = Math.floor(duration % 60)
      secs = if secs > 9 then secs else "0" + secs
      $('#track_duration').text("时长：" + mins + ":" + secs)

  # 1.提交前将标签传入hidden field
  # 2.获取音乐的duration
  $("#track-submit").on "click", (e) ->
    e.preventDefault()
    if $('#boom_track_file').val() == ""
      alert '请上传音乐'
      return
    else if $('#boom_track_name').val() == ""
      alert '请填写标题'
      return
    else
      #1
      $("#boom_tag_ids").val($('select#tags').val())
      #2
      duration = $("#track-file-pre")[0].duration
      if duration
        $("#boom_track_duration").attr("value", duration)
      $("form").submit()

  ####### 列表页
  # 音乐播放
  $('.track_files').removeClass('track_playing')
  $('table.tracks tr td').removeClass('td_playing')
  $('#track_player').hide()

  $('.track_files').on 'click', ->
    $('.track_files').removeClass('track_playing')
    $('table.tracks tr td').removeClass('td_playing')
    src = $(this).attr('data-src')
    id = $(this).attr('id')
    $('#track_player').attr('src', src).attr('autoplay', 'autoplay')
    $(this).addClass('track_playing')
    $('.track_playing').parent().addClass('td_playing')
