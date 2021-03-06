refresh_comments_list = (topic_id) ->
  $.get("/operation/topics/#{topic_id}/refresh_comments")

$ ->
  topic_id = $("#topic_id").val()
  if topic_id
    refresh_comments_list(topic_id)

  $("#newModal").on "click", ".add_comment", (e) ->
    $("#newModal").on "hidden.bs.modal", () ->
      location.reload()
    e.preventDefault()
    content = $("#comment_content").val()
    if content.length < 1
      alert("不能发空回复")
    else
      $.post("/operation/topics/#{topic_id}/add_comment", {content: content, creator: $("#creator").val()}, (data)->
        if data.success
          location.reload()
      ) # 新建comment

  $(".comments_list").on "click", ".reply_btn", ()->
    $("#replyModal").on "hidden.bs.modal", () ->
      location.reload()
    $("#replyModal").modal('show')
    $("#parent_id").val($(this).parent().data("id"))
    $("#replyModal .add_comment").on "click", (e) ->
      e.preventDefault()
      content = $("#reply_content").val()
      if content.length < 1
        alert("不能发空回复")
      else
        $.post("/operation/topics/#{topic_id}/add_comment", {content: content, creator: $("#reply_creator").val(), parent_id: $("#parent_id").val()}, (data)->
          if data.success
            location.reload()
        )  # 回复comment

  $(".comments_list").on "click", ".del_comment", ()->
    if confirm("确定要删除?")
      $.post("/operation/topics/#{topic_id}/destroy_comment", {_method: 'delete', comment_id: $(this).parent().data("id")}, (data)->
        if data.success
          location.reload()
      )  # 删除comment


  # 回复topic
  $(".topics").on "click", ".reply_btn", ()->
    $("#replyModal").on "hidden.bs.modal", () ->
      location.reload()
    $("#replyModal").modal('show')
    topic_id = $(this).parent().data("id")
    city_id = $("#city_topics").data('id')
    $("#replyModal .add_comment").on "click", (e) ->
      e.preventDefault()
      content = $("#reply_content").val()
      if content.length < 1
        alert("不能发空回复")
      else
        $.post("/operation/topics/#{topic_id}/add_comment", {content: content, creator: $("#reply_creator").val()}, (data)->
          if data.success
            location.reload()
        )

  # 删除topic
  $(".topics_index_list").on "click", ".del_topic", ()->
    if confirm("确定要删除?")
      topic_id = $(this).parent().data("id")
      $.post("/operation/topics/#{topic_id}/destroy_topic", {_method: 'delete'}, (data)->
        if data.success
          location.reload()
      )
