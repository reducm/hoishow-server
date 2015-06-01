$ ->
  data = $("#hoishow").data()

  generate_options = (subjects = [])->
    result = ""
    for subject in subjects
      result += "<option value='#{subject.id}'>#{subject.name}</option>"
    result

  $("#subject_type_select").on "change", (e)->
    select = $(e.currentTarget)
    selected_option = select.find("option:selected")
    if selected_option.val() == "Article"
      $('.editor').removeClass('hidden')
      $('.banner_subject_id').hide()
    else
      $('.editor').addClass('hidden')
      $('.banner_subject_id').show()
    key = selected_option.val().toLowerCase() + "s"
    subjects = data[key]
    options = generate_options(subjects)
    $("#subject_id_select").html(options)
    $("#subject_id_select").attr("data-live-search", true)
    $("#subject_id_select").selectpicker("refresh")
