generate_options = (subjects = [])->
  result = ""
  for subject in subjects
    result += "<option value='#{subject.id}'>#{subject.name}</option>"
  result

$ ->
  if $('#boombox_messages_new').length > 0
    $('.boom_message_targets').hide()
    $('#boom_message_start_time').datetimepicker()
    data = $("#message_subject_data").data()

    $("#boom_message_subject_type").on "change", (e)->
      select = $(e.currentTarget)
      selected_option = select.find("option:selected")
      if selected_option.val() == "Collaborator"
        $('.boom_message_targets').show()
      else
        $('.boom_message_targets').hide()
      key = selected_option.val().toLowerCase()
      subjects = data[key]
      options = generate_options(subjects)
      $("#boom_message_subject_id").html(options)
      $("#boom_message_subject_id").attr("data-live-search", true)
      $("#boom_message_subject_id").selectpicker("refresh")
