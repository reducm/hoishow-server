(->
  # 进度条初始化
  init_progress = ->
    $('.progress-bar').attr("aria-valuenow", 0).css('width', 0 + '%').text(0 + '%')
    $('#upload_status').removeClass('alert-success').addClass('alert-warning').hide()
  # 初始化提示
  display_init = ->
    $('.progress').show()
    $('#upload_status').show()
    $('#upload_status').text('正在初始化')
    $('#track-submit').addClass('disabled').val('正在上传')
  # 进度条更新
  update_progress = (start, end) ->
    width = Math.round(start / end * 100.00)
    $('.progress-bar').attr("aria-valuenow", width).css('width', width + '%').text(width + '%')
  # 上传完成提示
  display_finished = ->
    $('#upload_status').show()
    $('#upload_status').removeClass('alert-warning').addClass('alert-success')
    $('#upload_status').text('上传成功')
  # 错误提示
  display_error = (error_message) ->
    $.notify error_message,
      globalPosition: 'top center'
      className: 'error'
  # 保存按钮可用
  unlock_command_buttons = ->
    $('#track-submit').removeClass('disabled').val('保存')

  _extend = (dst, src) ->
    for i of src
      dst[i] = src[i]
    return

  sortPropertiesByKey = (obj) ->
    keys = []
    sorted_obj = {}
    for key of obj
      if obj.hasOwnProperty(key)
        keys.push key
    keys.sort()
    i = 0
    while i < keys.length
      k = keys[i]
      sorted_obj[k] = obj[k]
      i++
    sorted_obj

  calcSign = (data, secret) ->
    if typeof data != 'object'
      return
    sortedData = sortPropertiesByKey(data)
    md5Str = ''
    for key of sortedData
      if key != 'signature'
        md5Str = md5Str + key + sortedData[key]
    sign = SparkMD5.hash(md5Str + secret)
    sign

  formatParams = (data) ->
    arr = []
    for name of data
      arr.push encodeURIComponent(name) + '=' + encodeURIComponent(data[name])
    arr.join '&'

  checkBlocks = (arr) ->
    indices = []
    idx = arr.indexOf(0)
    while idx != -1
      indices.push idx
      idx = arr.indexOf(0, idx + 1)
    indices

  upload = (path, fileSelector) ->
    init_progress()
    self = this
    blobSlice = File::slice or File::mozSlice or File::webkitSlice
    chunkSize = _config.chunkSize
    chunks = undefined
    async.waterfall [
      (callback) ->
        chunkInfo = chunksHash: {}
        files = undefined

        loadNext = ->
          fileReader = new FileReader
          fileReader.onload = frOnload
          fileReader.onerror = frOnerror
          start = currentChunk * chunkSize
          end = if start + chunkSize >= file.size then file.size else start + chunkSize
          blobPacket = blobSlice.call(file, start, end)
          fileReader.readAsArrayBuffer blobPacket
          return

        if fileSelector == undefined
          files = document.getElementById('file').files
        else
          files = document.querySelector(fileSelector).files
        if !files.length
          display_error('请先选择文件上传')
          return
        file = files[0]
        chunks = Math.ceil(file.size / chunkSize)
        if !file.slice
          chunkSize = file.size
          chunks = 1
        currentChunk = 0
        spark = new (SparkMD5.ArrayBuffer)

        frOnload = (e) ->
          chunkInfo.chunksHash[currentChunk] = SparkMD5.ArrayBuffer.hash(e.target.result)
          spark.append e.target.result
          currentChunk++
          if currentChunk < chunks
            loadNext()
          else
            chunkInfo.entire = spark.end()
            chunkInfo.chunksNum = chunks
            chunkInfo.file_size = file.size
            callback null, chunkInfo
            
            return
          return

        frOnerror = ->
          display_error('操作失败，请稍后重试')
          return

        loadNext()
        return
      (chunkInfo, callback) ->
        options =
          'path': path
          'expiration': _config.expiration
          'file_blocks': chunkInfo.chunksNum
          'file_size': chunkInfo.file_size
          'file_hash': chunkInfo.entire
        signature = undefined
        _extend options, self.options
        if self._signature
          signature = self._signature
        else
          signature = calcSign(options, _config.form_api_secret)
        policy = Base64.encode(JSON.stringify(options))
        paramsData =
          policy: policy
          signature: signature
        urlencParams = formatParams(paramsData)
        request = new XMLHttpRequest
        request.open 'POST', _config.api + _config.bucket + '/'
        request.setRequestHeader 'Content-type', 'application/x-www-form-urlencoded'

        request.onreadystatechange = ->
          if request.readyState == 4 and request.status == 0
            display_error('网络故障，请稍后重试')
            $('.track-file-uploader').val('')
            $('.progress').hide()
            $('#upload_status').hide()
            unlock_command_buttons()
        
        request.onload = (e) ->
          if request.status == 200
            if JSON.parse(request.response).status.indexOf(0) < 0
              return callback(new Error('file already exists'))
            callback null, chunkInfo, request.response
          else
            request.send urlencParams
          return
        request.send urlencParams
        display_init()
        return
      (chunkInfo, res, callback) ->
        res = JSON.parse(res)
        file = undefined
        if fileSelector == undefined
          file = document.getElementById('file').files[0]
        else
          file = document.querySelector(fileSelector).files[0]
        _status = res.status
        result = undefined
        async.until (->
          checkBlocks(_status).length <= 0
        ), ((callback) ->
          idx = checkBlocks(_status)[0]
          start = idx * chunkSize
          end = if start + chunkSize >= file.size then file.size else start + chunkSize
          packet = blobSlice.call(file, start, end)
          options =
            'save_token': res.save_token
            'expiration': _config.expiration
            'block_index': idx
            'block_hash': chunkInfo.chunksHash[idx]
          signature = calcSign(options, res.token_secret)
          policy = Base64.encode(JSON.stringify(options))
          formDataPart = new FormData
          formDataPart.append 'policy', policy
          formDataPart.append 'signature', signature
          formDataPart.append 'file', if chunks == 1 then file else packet
          request = new XMLHttpRequest

          request.onreadystatechange = (e) ->
            if e.currentTarget.readyState == 4 and e.currentTarget.status == 200
              $('#upload_status').hide()
              update_progress(end, file.size)
              _status = JSON.parse(e.currentTarget.response).status
              result = request.response
              setTimeout (->
                callback null
              ), 0
            else if e.currentTarget.readyState == 4 and e.currentTarget.status != 200
              request.open 'POST', _config.api + _config.bucket + '/', true
              request.send formDataPart
            return

          request.open 'POST', _config.api + _config.bucket + '/', true
          request.send formDataPart
          return
        ), (err) ->
          if err
            callback err
          callback null, chunkInfo, result
          return
        return
      (chunkInfo, res, callback) ->
        res = JSON.parse(res)
        options =
          'save_token': res.save_token
          'expiration': _config.expiration
        signature = calcSign(options, res.token_secret)
        policy = Base64.encode(JSON.stringify(options))
        formParams =
          policy: policy
          signature: signature
        formParamsUrlenc = formatParams(formParams)
        request = new XMLHttpRequest
        request.open 'POST', _config.api + _config.bucket + '/'
        request.setRequestHeader 'Content-type', 'application/x-www-form-urlencoded'

        request.onload = (e) ->
          if request.status == 200
            display_finished()
            unlock_command_buttons()
            callback null, request.response
          else
            callback null, request.response
          return

        request.send formParamsUrlenc
        return
    ], (err, res) ->
      event = undefined
      if err
        if typeof CustomEvent == 'function'
          event = new CustomEvent('error', 'detail': err)
          document.dispatchEvent event
          return
        else
          #IE compatibility
          event = document.createEvent('CustomEvent')
          event.initCustomEvent 'error', false, false, err
          document.dispatchEvent event
          return
      if typeof CustomEvent == 'function'
        event = new CustomEvent('uploaded', 'detail': JSON.parse(res))
        document.dispatchEvent event
      else
        #IE compatibility
        event = document.createEvent('CustomEvent')
        event.initCustomEvent 'uploaded', false, false, JSON.parse(res)
        document.dispatchEvent event
      return
    return

  Sand = (config) ->
    _extend _config, config
    if config.signature
      @_signature = config.signature

    @setOptions = (options) ->
      @options = options
      return

    @upload = upload
    return

  'use strict'

  ###*
  #
  #  Base64 encode / decode
  #  http://www.webtoolkit.info/
  #
  ###

  Base64 = 
    _keyStr: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='
    encode: (input) ->
      output = ''
      chr1 = undefined
      chr2 = undefined
      chr3 = undefined
      enc1 = undefined
      enc2 = undefined
      enc3 = undefined
      enc4 = undefined
      i = 0
      input = Base64._utf8_encode(input)
      while i < input.length
        chr1 = input.charCodeAt(i++)
        chr2 = input.charCodeAt(i++)
        chr3 = input.charCodeAt(i++)
        enc1 = chr1 >> 2
        enc2 = (chr1 & 3) << 4 | chr2 >> 4
        enc3 = (chr2 & 15) << 2 | chr3 >> 6
        enc4 = chr3 & 63
        if isNaN(chr2)
          enc3 = enc4 = 64
        else if isNaN(chr3)
          enc4 = 64
        output = output + @_keyStr.charAt(enc1) + @_keyStr.charAt(enc2) + @_keyStr.charAt(enc3) + @_keyStr.charAt(enc4)
      output
    decode: (input) ->
      output = ''
      chr1 = undefined
      chr2 = undefined
      chr3 = undefined
      enc1 = undefined
      enc2 = undefined
      enc3 = undefined
      enc4 = undefined
      i = 0
      input = input.replace(/[^A-Za-z0-9\+\/\=]/g, '')
      while i < input.length
        enc1 = @_keyStr.indexOf(input.charAt(i++))
        enc2 = @_keyStr.indexOf(input.charAt(i++))
        enc3 = @_keyStr.indexOf(input.charAt(i++))
        enc4 = @_keyStr.indexOf(input.charAt(i++))
        chr1 = enc1 << 2 | enc2 >> 4
        chr2 = (enc2 & 15) << 4 | enc3 >> 2
        chr3 = (enc3 & 3) << 6 | enc4
        output = output + String.fromCharCode(chr1)
        if enc3 != 64
          output = output + String.fromCharCode(chr2)
        if enc4 != 64
          output = output + String.fromCharCode(chr3)
      output = Base64._utf8_decode(output)
      output
    _utf8_encode: (string) ->
      string = string.replace(/\r\n/g, '\n')
      utftext = ''
      n = 0
      while n < string.length
        c = string.charCodeAt(n)
        if c < 128
          utftext += String.fromCharCode(c)
        else if c > 127 and c < 2048
          utftext += String.fromCharCode(c >> 6 | 192)
          utftext += String.fromCharCode(c & 63 | 128)
        else
          utftext += String.fromCharCode(c >> 12 | 224)
          utftext += String.fromCharCode(c >> 6 & 63 | 128)
          utftext += String.fromCharCode(c & 63 | 128)
        n++
      utftext
    _utf8_decode: (utftext) ->
      string = ''
      i = 0
      c = c1 = c2 = 0
      while i < utftext.length
        c = utftext.charCodeAt(i)
        if c < 128
          string += String.fromCharCode(c)
          i++
        else if c > 191 and c < 224
          c2 = utftext.charCodeAt(i + 1)
          string += String.fromCharCode((c & 31) << 6 | c2 & 63)
          i += 2
        else
          c2 = utftext.charCodeAt(i + 1)
          c3 = utftext.charCodeAt(i + 2)
          string += String.fromCharCode((c & 15) << 12 | (c2 & 63) << 6 | c3 & 63)
          i += 3
      string
  _config =
    api: 'http://m0.api.upyun.com/'
    chunkSize: 1048576
  # bind the construct fn. to global
  @Sand = Sand
  return
).call this

# ---
# generated by js2coffee 2.1.0
