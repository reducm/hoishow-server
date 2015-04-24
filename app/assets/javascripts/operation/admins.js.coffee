$ ->
  $("#submit").on "click", (e) ->
    $("#pw1").val() != $("#pw2").val() 
    $("#error_msg").text("两次输入的密码不一样，请重新输入")
    e.preventDefault()
    $("#submit").attr("disabled", ture)
