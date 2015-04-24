refresh_comments_list = (topic_id) ->
  $.get("/operation/topics/#{topic_id}/refresh_comments")

$ ->
  topic_id = $("#topic_id").val()
  if topic_id
    refresh_comments_list(topic_id)

  $("#newModal").on "click", ".add_comment", (e) ->
    e.preventDefault()
    $.post("/operation/topics/#{topic_id}/add_comment", {content: $("#comment_content").val(), creator: $("#creator").val()}, (data)->
      if data.success
        $("#newModal, .modal-backdrop").hide()
        refresh_comments_list(topic_id)
    ) # 新建comment

  $(".comments_list").on "click", ".reply_btn", ()->
    $("#replyModal").modal('show')
    $("#parent_id").val($(this).parent().data("id"))
    $("#replyModal .add_comment").on "click", (e) ->
      e.preventDefault()
      $.post("/operation/topics/#{topic_id}/add_comment", {content: $("#reply_content").val(), creator: $("#reply_creator").val(), parent_id: $("#parent_id").val()}, (data)->
        if data.success
          $("#replyModal, .modal-backdrop").hide()
          refresh_comments_list(topic_id)
      )  # 回复comment

  $(".comments_list").on "click", ".del_comment", ()->
    if confirm("确定要删除?")
      $.post("/operation/topics/#{topic_id}/destroy_comment", {_method: 'delete', comment_id: $(this).parent().data("id")}, (data)->
        if data.success
          refresh_comments_list(topic_id)
      )  # 删除comment
