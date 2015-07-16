refresh_topic_list = (star_id)->
  $.get("/operation/stars/#{star_id}/get_topics", (data)->
    $("#star_topics").html(data)
  )
# 刷新topic列表
$ ->
  Dropzone.options.videoDzForm =
    acceptedFiles: ".mp4"
    dictDefaultMessage: "选择文件或直接拖进来"
    dictFileTooBig: "文件太大，请重新选择"
    init: ->
        @on 'success', (file, responseText) ->
          file.previewTemplate.appendChild document.createTextNode "上传完毕"
    maxFilesize: 30

  $('#status_select').change ->
    $(".status_cn").parent().show()
    vtxt = $('#status_select').val()
    if vtxt == "全部"
      location.reload()
    else
      $(".status_cn:not(:contains('" + vtxt + "'))").parent().hide()
      $( '#stars_list'  ).sortable( "disable"  )
      $('.handle').hide()

  star_id = $("#star_id").val()
  if star_id
    $(".add_topic").on "click", ()->
      $("#topicModal").on "hidden.bs.modal", () ->
        location.reload()
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
      $("#replyModal").on "hidden.bs.modal", () ->
        location.reload()
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

  # 删除topic
  $(".star_show_topics_list").on "click", ".del_topic", ()->
    if confirm("确定要删除?")
      topic_id = $(this).parent().data("id")
      $.post("/operation/topics/#{topic_id}/destroy_topic", {_method: 'delete'}, (data)->
        if data.success
          location.reload()
      )
