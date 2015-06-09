$ ->
  $(".comments_index_list").on "click", ".reply_btn", ()->
    $("#replyModal").modal('show')
    topic_id = $(this).parent().data("topic-id")
    $("#parent_id").val($(this).parent().data("id"))
    $("#topic_id").val(topic_id)
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

  $(".comments_index_list").on "click", ".del_comment", ()->
    if confirm("确定要删除?")
      topic_id = $(this).parent().data("topic-id")
      $.post("/operation/topics/#{topic_id}/destroy_comment", {_method: 'delete', comment_id: $(this).parent().data("id")}, (data)->
        if data.success
          location.reload()
      )  # 删除comment


