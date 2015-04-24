refresh_comments_list = (topic_id) ->
  $.get("/operation/topics/#{topic_id}/refresh_comments")

$ ->
  topic_id = $("#topic_id").val()
  refresh_comments_list(topic_id)

  $("#commentModal").on "click", ".add_comment", (e) ->
    e.preventDefault()
    $.post("/operation/topics/#{topic_id}/add_comment", {content: $("#comment_content").val(), creator: $("#creator").val()}, (data)->
      if data.success
        $("#commentModal, .modal-backdrop").hide()
        refresh_comments_list(topic_id)
    )