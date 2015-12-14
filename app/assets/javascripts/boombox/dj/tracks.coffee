$ ->
  ####### 编辑页
  # 上传图片后隐藏默认占位图
  $('input#boom_track_cover').on 'change', ->
    $('div#track_cover_preview').hide()
    readURL this

  # 文本框标签化
  $(document).ready ->
    $('#boom_track_artists').tagit
      allowSpaces: true

  # 标签
  if $('div#tags_already_added').length > 0
    $('select#tags').val($('div#tags_already_added').data('data')).select2
      tags: true
  else
    $('select#tags').select2
      tags: true

  # 上传音乐后显示文件信息
  $('.track-file-uploader').change ->
    if this.files[0]
      reader = new FileReader
      reader.onload = (e) ->
        $("#track-file-pre").attr("src", e.target.result).attr("controls", "controls")
      reader.readAsDataURL this.files[0]

      name = this.files[0].name
      filename = name.replace(/\.[^/.]+$/, "")
      size = Math.round(this.files[0].size / 1024 / 1024 * 100) / 100
      $('#current_file').attr('data-url', 'true')
      $('#boom_track_name').val(filename)
      $('#track_filename').text("文件：" + name)
      $('#track_size').text("大小：" + size + " MB")
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
    if $('#current_file').attr('data-url') == ""
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
