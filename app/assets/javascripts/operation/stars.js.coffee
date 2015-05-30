refresh_topic_list = (star_id)->
  $.get("/operation/stars/#{star_id}/get_topics", (data)->
    $("#star_topics").html(data)
  )
# 刷新topic列表
$ ->
  $('#stars_list').sortable(
    axis: 'y'
    handle: '.handle'
    update: ->
      $.post($(this).data('update-url'), $(this).sortable('serialize'))
      location.reload()
  )

  $('#status_select').change ->
    $(".status_cn").parent().show()
    vtxt = $('#status_select').val()
    if vtxt == "全部"
      location.reload()
    else
      $(".status_cn:not(:contains('" + vtxt + "'))").parent().hide()
      $( '#stars_list'  ).sortable( "disable"  )
      $('.handle').hide()

  $('#stars').dataTable(
    paging: false
  )

  if $(".concerts_list").length > 0
    $(".concerts").dataTable()

  if $(".topics_list").length > 0
    $(".topics").dataTable()

  if $(".users_list").length > 0
    $(".users").dataTable()

  star_id = $("#star_id").val()
  if star_id
    $(".add_topic").on "click", ()->
      $("#topicModal").modal('show')
      $("#topicModal .create_topic").on "click", (e)->
        e.preventDefault()
        content = $("#topic_content").val()
        if content.length < 1
          alert("不能发空互动")
        else
          $.post("/operation/topics", {topic: {subject_id: star_id, subject_type: 'Star'}, creator: $('#topic_creator').val(), content: content}, (data)->
            if data.success
              location.reload()
          )
    # 创建topic

    $("#star_topics").on "click", ".reply_btn", ()->
      $("#replyModal").modal('show')
      topic_id = $(this).parent().data("id")
      $("#replyModal .add_comment").on "click", (e) ->
        e.preventDefault()
        content = $("#reply_content").val()
        if content.length < 1
          alert("不能发空回复")
        else
          $.post("/operation/topics/#{topic_id}/add_comment", {content: content, creator: $("#reply_creator").val()}, (data)->
            if data.success
              $("#replyModal").modal('toggle')
              $('body').removeClass('modal-open')
              $('.modal-backdrop').remove()
              refresh_topic_list(star_id)
          )
    # 回复comment
