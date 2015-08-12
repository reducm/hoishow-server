init_editor = ()->
  editor = new Simditor({
             textarea: $('#banner_description'),
             upload: {
               url: '/simditor_image',
               connectionCount: 3,
               leaveConfirm: '正在上传文件，如果离开上传会自动取消'
             },
             toolbar: ['link', 'image', '|', 'title', 'bold', 'italic', 'color','|', 'underline', 'strikethrough', 'hr', 'html'],
             pasteImage: true
           })

$ ->
  $('.image-uploader').change ->
    readURL this

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
      init_editor()
    else
      $('.editor').addClass('hidden')
    key = selected_option.val().toLowerCase() + "s"
    subjects = data[key]
    options = generate_options(subjects)
    $("#subject_id_select").html(options)
    $("#subject_id_select").attr("data-live-search", true)
    $("#subject_id_select").selectpicker("refresh")

  if $('#subject_type_select').val() == 'Article'
    $('.editor').removeClass('hidden')
    init_editor()
