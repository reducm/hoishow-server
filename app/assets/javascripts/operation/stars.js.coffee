refresh_topic_list = (star_id)->
  $.get("/operation/stars/#{star_id}/get_topics", (data)->
    $("#star_topics").html(data)
  )
# 刷新topic列表
$ ->
  $('.image-uploader').change ->
    readURL this

  Dropzone.options.videoDzForm =
    acceptedFiles: ".mp4"
    dictDefaultMessage: "选择文件或直接拖进来"
    dictFileTooBig: "文件太大，请重新选择"
    init: ->
        @on 'success', (file, responseText) ->
          file.previewTemplate.appendChild document.createTextNode "上传完毕"
    maxFilesize: 30

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

## 艺人列表过滤开始 ##
  f_data = $('#stars_filter').data()

  StarLists = do ->
    loadTable = ->
      if !jQuery().DataTable
        return
      starTable = $("#stars_table").DataTable(
        # 基本配置
        stateSave: true
        ordering: false
        # 语言文件放在public下面
        language:
          url: "/Chinese.json"
        # 从服务器的Order#index获取数据
        processing: true
        serverSide: true
        # 把过滤条件回传服务器
        ajax:
          url: $("#stars_table").data("source")
          data: (d) ->
            $.extend {}, d,
              'status': $('#status_filter').val()
              # 控件有问题，现固定每页显示10行
              'length': 10
        initComplete: ->
          api = @api()
          # 按艺人状态过滤
          select = $('<select><option selected="selected" value="">艺人状态：全部</option></select>').attr("id", "status_filter").addClass('form-control stars_filters').appendTo($("#stars_table_length")).on 'change', ->
            api.ajax.reload()
          $.each f_data["statusFilter"], (key, value) ->
            select.append '<option value="' + value + '">' + "艺人状态：" + key + '</option>'
          # 文本搜索提示
          $('div#stars_table_filter.dataTables_filter label input').attr('placeholder', '艺人名字').removeClass('input-sm')
          # 隐藏显示行数控件
          $('#stars_table_length label:first').hide()
      )
    {
      init: ->
        loadTable()
    }

  jQuery(document).ready ->
    StarLists.init()
## 艺人列表过滤结束 ##
