$ ->
  $('.track-cover-uploader').change ->
    readURL this

  $('.track-file-uploader').change ->
    if this.files[0]
      reader = new FileReader
      reader.onload = (e) ->
        $("#track-file-pre").attr("src", e.target.result).attr("controls", "controls")
      reader.readAsDataURL this.files[0]
    return

  $("#track-submit").on "click", (e) ->
    duration = $("#track-file-pre")[0].duration
    if duration
      $("#boom_track_duration").attr("value", duration)
    $("form").submit()
