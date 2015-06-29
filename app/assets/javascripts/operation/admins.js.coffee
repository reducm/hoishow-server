$ ->
  #admins edit
  $("#submit").on "click", (e) ->
    if $("#pw1").val() != $("#pw2").val()
      $("#error_msg").text("两次输入的密码不一样，请重新输入")
      e.preventDefault()
    else
      $("form").submit()

  #admins new
  $("#admins_new_submit").on "click", (e) ->
    if $("#username").val() == "" or $("#password").val() == ""
      $("#admins_new_error_msg").text("用户名或者密码不能为空")
      e.preventDefault()
