$ ->
  re_for_pw = /^\w+$/
  #admins edit
  $("#boom_admin_edit_submit").on "click", (e) ->
    if $("#boom_admin_edit_pw1").val() != $("#boom_admin_edit_pw2").val()
      $("#boom_admin_edit_error_msg").text("两次输入的密码不一样，请重新输入").css("color", "red")
      e.preventDefault()
    else if !re_for_pw.test($("#boom_admin_edit_pw1").val())
      $("#boom_admin_edit_error_msg").text("密码只支持英文／数字／下划线").css("color", "red")
      $("#boom_admin_edit_pw1").focus()
      e.preventDefault()
    else
      $("form").submit()

  #admins new
  $("#boom_admin_new_submit").on "click", (e) ->
    if $("#boom_admin_new_username").val() == "" or $("#boom_admin_new_password").val() == ""
      $("#boom_admin_new_error_msg").text("用户名或者密码不能为空").css("color", "red")
      e.preventDefault()
