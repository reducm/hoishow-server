generate_options = (subjects = [])->
  result = ""
  for subject in subjects
    result += "<option value='#{subject.id}'>#{subject.name}</option>"
  result

$ ->
  $('#boom_banner_poster').change ->
    if $('#boom_banner_poster_exist').length > 0
      $('#boom_banner_poster_exist').hide()
    readURL this

  if $('#boom_banner_form').length > 0
    data = $("#boom_banner_subject_data").data()

    $("#boom_banner_subject_type").on "change", (e)->
      select = $(e.currentTarget)
      selected_option = select.find("option:selected")
      key = selected_option.val().toLowerCase()
      subjects = data[key]
      options = generate_options(subjects)
      $("#boom_banner_subject_id").html(options).attr("data-live-search", true).selectpicker("refresh")
