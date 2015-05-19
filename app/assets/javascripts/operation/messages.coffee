$ ()->
  data = $("#message_creator_data").data()

  generate_options = (subjects = [])->
    result = ""
    for subject in subjects
      result += "<option value='#{subject.id}'>#{subject.name}</option>"
    result

  $("#message_creator_type_select").on "change", (e)->
    select = $(e.currentTarget)
    selected_option = select.find("option:selected")
    if selected_option.val() == "All"
      $('#message_creator_id').hide()
    else
      $('#message_creator_id').show()
    key = selected_option.val().toLowerCase() + "s"
    console.log key
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

  if $(".messages_list").length > 0
    $(".messages").dataTable()
