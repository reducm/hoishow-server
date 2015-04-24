$ ->
  $("#submit").on "click", (e) ->
    if $("#pw1").val() != $("#pw2").val() or $("#pw1").val() == "" or $("#pw2").val() == ""
      $("#error_msg").text("两次输入的密码不一样，请重新输入")
      e.preventDefault()
    else
      $("form").submit()
