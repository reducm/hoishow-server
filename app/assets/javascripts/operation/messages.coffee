generate_options = (subjects = [])->
  result = ""
  for subject in subjects
    result += "<option value='#{subject.id}'>#{subject.name}</option>"
  result

$ ()->
  data = $("#message_creator_data").data()

  $("#message_creator_type_select").on "change", (e)->
    select = $(e.currentTarget)
    selected_option = select.find("option:selected")
    if selected_option.val() == "All"
      $('#message_creator_id').hide()
      $('.target').show()
    else
      $('#message_creator_id').show()
      $('.target').hide()
    key = selected_option.val().toLowerCase() + "s"
    subjects = data[key]
    options = generate_options(subjects)
    $("#message_creator_id_select").html(options)
    $("#message_creator_id_select").attr("data-live-search", true)
    $("#message_creator_id_select").selectpicker("refresh")

  $("#message_subject_type_select").on "change", (e)->
    select = $(e.currentTarget)
    selected_option = select.find("option:selected")
    key = selected_option.val().toLowerCase() + "s"
    subjects = data[key]
    options = generate_options(subjects)
    $("#message_subject_id_select").html(options)
    $("#message_subject_id_select").attr("data-live-search", true)
    $("#message_subject_id_select").selectpicker("refresh")

  $('.submit_message').on 'click', (e)->
    e.preventDefault()
    creator_type = $('#message_creator_type_select').val()
    creator_id = $('#message_creator_id_select').val()
    unless creator_type == 'All'
      $('#message_subject_type_select').append("<option value=#{creator_type} selected></option>")
      $('#message_subject_id_select').append("<option value=#{creator_id} selected></option>")
    $(this).parent('form').submit()
