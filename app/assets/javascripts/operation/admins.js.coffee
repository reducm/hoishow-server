$ ->
  re_for_pw = /^\w+$/
  #admins edit
  $("#submit").on "click", (e) ->
    if $("#pw1").val() != $("#pw2").val()
      $("#error_msg").text("两次输入的密码不一样，请重新输入").css("color", "red")
      e.preventDefault()
    else if !re_for_pw.test($("#pw1").val()) or !re.test($("#pw1").val())
      $("#error_msg").text("密码只支持英文／数字／下划线").css("color", "red")
      $("#pw1").focus()
      e.preventDefault()
    else
      $("form").submit()

  #admins new
  $("#admins_new_submit").on "click", (e) ->
    if $("#username").val() == "" or $("#password").val() == ""
      $("#admins_new_error_msg").text("用户名或者密码不能为空")
      e.preventDefault()
