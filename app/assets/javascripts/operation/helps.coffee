init_editor = ()->
  editor = new Simditor({
             textarea: $('#help_description'),
             upload: {
               url: '/simditor_image',
               connectionCount: 3,
               leaveConfirm: '正在上传文件，如果离开上传会自动取消'
             },
             toolbar: ['link', 'image', '|', 'title', 'bold', 'italic', 'color','|', 'underline', 'strikethrough', 'hr', 'html'],
             pasteImage: true
           })

$ ->
  init_editor() if $('#help_description').length > 0
