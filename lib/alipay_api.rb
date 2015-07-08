# coding: utf-8
require 'openssl'
require 'base64'
logger = Logger.new(File.join(Rails.root, 'log', 'alipay_api.log'))

module AlipayApi
  Settings = YAML.load_file(File.join "#{Rails.root}", "config", "settings", "alipay.yml")

  #支付宝公众账号开发者验证
  def alipublic_develop_vefify(content)
    biz_content = Settings["rsa_pub_key"]
    sign_str =  "<success>true</success><biz_content>#{biz_content}</biz_content>"
    sign = rsa_sign(sign_str, pri_key_file)
    response = <<-XML
      <?xml version="1.0" encoding="GBK"?><alipay><response><success>true</success><biz_content>#{biz_content}</biz_content></response><sign>#{sign}</sign><sign_type>RSA</sign_type></alipay>
    XML
    Rails.logger.fatal("---------virify: #{response}")
    response.gsub(/\n+/,'').strip
  end

  # 用户信息授权接口
  def user_info_authorize(settings=Settings)
    options = {
      service: "alipay.auth.authorize",
      return_url: alipay_auth_return_users_url,
      partner: settings["pid"],
      _input_charset: "utf-8",
      target_service: "user.auth.quick.login"
    }
    options.merge!({
      sign: generate_md5_sign(options),
      sign_type: "MD5",
    })
    request_url = "#{settings["api_url"]}?#{options.to_query}"
  end

  def create_direct_pay_by_user(order, notify_url = alipay_notify_url, return_url = alipay_return_url)
    options = {
      service: "create_direct_pay_by_user",
      payment_type: "1",
      out_trade_no: order.out_id,
      subject: order.alipay_subject,
      total_fee: order.total_fee,
      #price: order.unit_price,
      #quantity: order.quantity,
      notify_url: notify_url,
      return_url: return_url,
      partner: Settings["PCpid"],
      seller_email: Settings["PC_email"],
      it_b_pay: "10m",
      _input_charset: "utf-8"
    }

    options.merge!( {
      sign: generate_md5_sign(options,Settings["PC_md5_key"]),
      sign_type: "MD5"
    })

  end

  # 支付宝钱包统一并支付接口
  def create_and_pay(order)
    options = {
      service: "alipay.acquire.createandpay",
      sign_type: "MD5",
      notify_url: alipay_notify_url,
      out_trade_no: order.out_id,
      subject: order.alipay_subject,
      product_code: "BARCODE_PAY_OFFLINE"
    }
  end

  #即时到账批量退款接口 orders 最大支持1000笔
  def refund_fastpay(orders, settings=Settings)
    #TODO 参数检查
    options = {
      service: "refund_fastpay_by_platform_nopwd",
      partner: settings["pid"],
      _input_charset: "utf-8",
      sign_type: "MD5",
      notify_url: settings["refund_url"] ,
      seller_email: settings["email"],
      seller_user_id: settings["pid"],
      refund_date: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
      batch_no: create_batch_no,
      batch_num: orders.length,
      detail_data: create_refund_detail(orders)
    }
    options.merge!({
      sign:generate_md5_sign(options)
    })

    #puts JSON.pretty_generate options
    Refund.create options.slice(:batch_no, :batch_num, :detail_data)

    request_url = "#{settings["api_url"]}?#{options.to_query}"
      #puts request_url
    response =  RestClient.get request_url
    xml = Nokogiri::XML(response)
    #puts xml
    if xml.css("is_success").first.content == "T"
      return true
    else
      return xml.css("error").first.content
    end
  end

  def create_batch_no
    #退款批次号： 格式：退款日期(8 位) +流水号(3~24 位) 能接受英文字符。
    #目前采用8位数字流水号，例如2011011200000001
    #TODO 超过8位的处理
    Date.today.strftime("%Y%m%d") + "%08d" % ( Refund.where(created_at: Date.today.beginning_of_day...Date.tomorrow.beginning_of_day).count + 1 )
  end

  def create_refund_detail(orders)
    # 单笔数据集格式为: 第一笔交易退款数据集#第二笔交易退款数据集...#第 N 笔交易退款数据集
    # 交易退款数据集的格式为: 原付款支付宝交易号^退款总金额^退款理由;
    detail = []
    for order in orders
      #TODO 检验trade_no 已经 amount不存在的情况
      detail.push "#{order.trade_no}^#{order.amount}^未出票"
    end
    detail.join("#")
    #orders.map{|order| "#{order.trade_no}^#{order.amount}^未出票"}.join("#")
  end

  #手机网页即时到账授权接口
  def create_wap_trade(order, type="alipublic", settings=Settings)
    options = {
      service: "alipay.wap.trade.create.direct",
      format: "xml",
      v: "2.0",
      _input_charset: "utf-8",
      partner: settings["pid"],
      req_id: Time.current.to_i.to_s, #时间戳作为请求号
      sec_id: "MD5",
      req_data: create_wap_trade_data(order, type)
    }
    options.merge!({
      sign:generate_md5_sign(options)
    })

    #puts JSON.pretty_generate  options

    request_url = "#{settings["wap_api_url"]}?#{options.to_query}"
    puts request_url
    begin
      response =  RestClient.post request_url, nil
      puts URI.decode response
      #获取request_token
      Nokogiri::XML(CGI.parse(response)["res_data"][0]).css("request_token").first.content
    rescue Exception
      Rails.logger.fatal("-------create_wap_trade: #{$!} \n #{$@.to_s} \n------\n\n")
      return nil
    end
  end

  #手机网页即时到账交易接口
  def execute_wap_trade(token, settings=Settings)
    options = {
      service: "alipay.wap.auth.authAndExecute",
      format: "xml",
      v: "2.0",
      partner: settings["pid"],
      sec_id: "MD5",
      req_data: "<auth_and_execute_req><request_token>#{token}</request_token></auth_and_execute_req>"
    }
    options.merge!({
      sign:generate_md5_sign(options)
    })

    execute_wap_trade_url = "#{settings["wap_api_url"]}?#{options.to_query}"
    return execute_wap_trade_url
  end

  def create_wap_trade_data(order, type="alipublic", settings=Settings)
    "<direct_trade_create_req>
          <subject>电影票</subject>
          <out_trade_no>#{order.out_id }</out_trade_no>
          <total_fee>#{order.amount.round(2)}</total_fee>
          <seller_account_name>#{settings["email"]}</seller_account_name>
          <call_back_url>#{alipay_wap_return_url(type)}</call_back_url>
          <notify_url>#{alipay_wap_notify_url(type)}</notify_url>
          <out_user>#{order.user_id}</out_user>
          <pay_expire>15</pay_expire>
      </direct_trade_create_req>".gsub(/\s+/,'')
  end

  #获取用户地理位置信息接口
  def public_gis_get(user, settings=Settings)
    #biz_content:'{"user_id":"#{user.authentications.where(provider:"alipay").first.uid}"}',
    #test user_id: 2088102130996702
    options = {
      method: "alipay.mobile.public.gis.get",
      app_id: settings["sandbox_app_id"],
      sign_type: "RSA",
      charset: "utf-8",
      timestamp: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
      biz_content: '{"userId": "2088102133217970"}'
    }

    options.merge!({
      sign:rsa_sign(sort_options_to_str(options), pri_key_file)
    })

    #puts JSON.pretty_generate  options
    request_url = "#{settings["api_url"]}?#{options.to_query}"
      #puts request_url
    response =  RestClient.post request_url, nil
    #puts response
    JSON.parse(response)["alipay_mobile_public_gis_get_response"]
  end

  #生成alipass，支付宝卡卷接口
  #TODO 替换user_id app_id等数据
  def alipass_sync_add(order, settings=Settings)
    options = {
      method: "alipay.pass.sync.add",
      timestamp: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
      app_id: settings["alipass_app_id"],
      version: "1.0",
      charset: "utf-8",
      sign_type: "RSA",
      #user_id:"#{order.user.alipay_uid}", #不建议使用user_id,优先使用out_trade_no
      out_trade_no: order.out_id.to_s,
      file_content: create_alipass_content(order),
      partner_id: settings["pid"]
    }

    #pri_key = File.read("#{Rails.root}/lib/rsa_test_pkcs8.txt")
    # pri_key = File.read("#{Rails.root}/lib/rsa_private_key.pem")

    options.merge!({
      sign:rsa_sign(sort_options_to_str(options), pri_key_file),
    })

    response =  RestClient.post settings["api_url"], options
    puts response
    Rails.logger.fatal("---------alipass add response: #{response} -------------------")
    biz_result = JSON.parse(response)["alipay_pass_sync_add_response"]["biz_result"]
    passId =  JSON.parse(biz_result)["passId"]
    order.update_attributes({alipassId:passId})
  end

  def alipass_sync_update(order, settings=Settings)
    options = {
      method: "alipay.pass.sync.update",
      timestamp: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
      app_id: settings["#{respond_to?(:prefix_path) ? prefix_path + '_' : ''}app_id"],
      version: "1.0",
      charset: "utf-8",
      sign_type: "RSA",
      #user_id:"2088102008238264", #TODO 不建议使用user_id,优先使用out_trade_no
      out_trade_no: order.out_id,
      partner_id: settings["alipass_partner_id"],
      serial_number: order.alipass_serial,
      status: "USED",
      verify_type: "wave",
    }

    pri_key = File.read("#{Rails.root}/lib/rsa_test_pkcs8.txt")
    options.merge!({
      sign:rsa_sign(sort_options_to_str(options), pri_key),
    })

    response =  RestClient.post settings["online_api_url"], options
    puts response
  end

  def alipass_code_verify(order, settings=Settings)
    options = {
      method: "alipay.pass.code.verify",
      timestamp: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
      app_id: settings["alipass_app_id"],
      version: "1.0",
      charset: "utf-8",
      sign_type: "RSA",
      user_id:"2088102008238264", #TODO 不建议使用user_id,优先使用out_trade_no
      #out_trade_no: order.id.to_s,
      partner_id: settings["alipass_partner_id"],
      operator_id: 2,
      verify_code: "123123",
      operator_type: 2
    }
    pri_key = File.read("#{Rails.root}/lib/rsa_test_pkcs8.txt")
    options.merge!({
      sign:rsa_sign(sort_options_to_str(options), pri_key),
    })

    response =  RestClient.post settings["online_api_url"], options
    puts response
  end

  def alipass_code_add(order, settings=Settings)
    options = {
      method: "alipay.pass.code.add",
      timestamp: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
      app_id: settings["alipass_app_id"],
      version: "1.0",
      charset: "utf-8",
      sign_type: "RSA",
      recognition_type: 2,      #1，订单信息；2 支付宝UserId
      #recognition_info: {user_id:"2088102008238264"}, #不建议使用user_id,优先使用out_trade_no
      recognition_info: {user_id:"#{order.user.alipay_uid}"}, #不建议使用user_id,优先使用out_trade_no
      #out_trade_no: order.id.to_s,
      file_content: create_alipass_content(order),
      partner_id: settings["alipass_partner_id"]
    }
    pri_key = File.read("#{Rails.root}/lib/rsa_test_pkcs8.txt")
    for_sign_string = sort_options_to_str(options)

    options.merge!({
      sign:rsa_sign(sort_options_to_str(options), pri_key),
    })
    puts rsa_verify?(for_sign_string,options[:sign],settings["alipass_rsa_pub_key"])
    response =  RestClient.post settings["online_api_url"], options
    puts response

  end

  def create_alipass_content(order)
    #pass_hash = Rabl.render(order,"alipass.rabl",view_path:"#{Rails.root}/lib", format:json)
    pass_hash = eval(ERB.new(File.read("#{Rails.root}/lib/alipass_content.json")).result(binding))
    #将pass_hash写入文件，然后zip打包，并用Base64编码输出
    pass_str = pass_hash.to_json
    File.open("#{Rails.root}/tmp/alipass/pass.json","w") do |f|
      f.write(pass_str)
    end

    #下载strip图片 到shared/alipass目录下
    #strip_path = "#{Rails.root}/shared/alipass/#{order.show.film.id}.strip"
    strip_path = "#{Rails.root}/tmp/alipass/#{order.film_id}.strip"
    %x(wget -O "#{strip_path}" "#{order.film.poster("small")}" ) unless File.exist?(strip_path)
    %x(cp "#{strip_path}" "#{Rails.root}/tmp/alipass/strip.png" )

    #自动生成SHA1 签名后的sigature
    pass_sha1 = OpenSSL::Digest::SHA1.new(pass_str).to_s
    strip_sha1 = %x(shasum "#{Rails.root}/tmp/alipass/strip.png").split(" ")[0]
    signature_hash = {
      "logo.png" => "a5354808d1da4696339be82034c345c2a1b7f3e0",
      "icon.png" =>"a5354808d1da4696339be82034c345c2a1b7f3e0",
      "strip.png" => strip_sha1,
      "pass.json" => pass_sha1
    }
    File.open("#{Rails.root}/tmp/alipass/signature","w") do |f|
      f.write(signature_hash.to_json)
    end

    %x(zip -j "#{Rails.root}/tmp/alipass/zip.alipass" "#{Rails.root}/tmp/alipass/pass.json" "#{Rails.root}/tmp/alipass/icon.png" "#{Rails.root}/tmp/alipass/strip.png" "#{Rails.root}/tmp/alipass/logo.png" "#{Rails.root}/tmp/alipass/signature")

    # 改用rubyzip打包文件
    #zip_folder = "#{Rails.root}/tmp/alipass/"
    #input_files = ['pass.json',"icon.png","logo.png","strip.png","signature"]
    #Zip::File.open("#{Rails.root}/tmp/alipass/zip.alipass",Zip::File::CREATE) do |zipfile|
    #end
    file_content = Base64.encode64(File.read("#{Rails.root}/tmp/alipass/zip.alipass"))
    %x(rm "#{Rails.root}/tmp/alipass/zip.alipass")

    return file_content
  end

  #公众账户向用户发送消息接口
  def public_message_push(order, settings=Settings)
    alipay_uid = order.user.authentications.where(provider:"alipay").first.uid rescue nil
    if alipay_uid.nil?
      Rails.logger.fatal("------------alipay push nil error -----------")
      return false
    else
      if order.status_success?
        title = "#{order.film_name}出票成功"
        desc  = "#{order.key}"
        #image_url = qr_mobile_order_url(order)+".png?qr=#{order.key}"
        image_url = order.film.stills.first(offset:rand(order.film.stills.count)).image
      else
        order.status_refund?
        desc = "出票失败,已退款"
        image_url = nil
      end
      options = {
        method: "alipay.mobile.public.message.push",
        app_id: settings["#{respond_to?(:prefix_path) ? prefix_path : ''}_app_id"],
        sign_type: "RSA",
        charset: "utf-8",
        timestamp: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
        biz_content: create_push_biz_content(order, alipay_uid, title,desc, image_url)
      }

      Rails.logger.fatal("---------push options #{options.inspect} ----------")
      options.merge!({
        sign:rsa_sign(sort_options_to_str(options), pri_key_file)
      })

      request_url = "#{settings["api_url"]}?#{options.to_query}"
      response =  RestClient.post request_url, nil
      Rails.logger.fatal("---------public response: #{response} -------------------")
      JSON.parse(response)["alipay_mobile_public_message_push_response"]["msg"] == "成功" rescue false
    end
  end

  def create_push_biz_content(order, alipay_uid, title="支付成功",desc="等待出票中...", image_url=nil, settings=Settings)
    #<ToUserId><![CDATA[2088102130996702]]></ToUserId>
    "
      <xml>
        <ToUserId><![CDATA[#{alipay_uid}]]></ToUserId>
        <AppId><![CDATA[#{settings["#{respond_to?(:prefix_path) ? prefix_path : ''}_app_id"]}]]></AppId>
        <CreateTime>#{Time.now.to_ms}</CreateTime>
        <MsgType><![CDATA[image-text]]></MsgType>
        <ArticleCount>1</ArticleCount>
        <Articles>
          <Item>
            <Title><![CDATA[#{title}]]></Title>
            <Desc><![CDATA[#{desc}]]></Desc>
            <ImageUrl><![CDATA[#{image_url}]]></ImageUrl>
            <Url><![CDATA[#{respond_to?(:prefix_path) ? send(prefix_path + '_order_url',order.out_id) : order_url(order.out_id)}]]></Url>
          </Item>
        </Articles>
        <Push><![CDATA[true]]></Push>
      </xml>
    "
  end

  def merge_default_options(options, settings=Settings)
  end

  def app_option_str_from_order(order)
    out_trade_no = Rails.env.production? ? "bike#{order.out_id}" : order.out_id
    option = {
      "service" =>  "mobile.securitypay.pay",
      "partner" =>  Settings["pid"],
      "seller_id" =>  Settings["email"],
      "_input_charset" => "utf-8",
      "notify_url" => Settings["notify_url"],
      "out_trade_no" => out_trade_no,
      "subject" => "#{order.film_name}电影票",
      "payment_type" => "1",
      "total_fee" => order.total_fee
    }
    signed_option_string = rsa_sign(sort_options_to_str(option), pri_app_key_file)
    "?#{ sort_options_to_str(option) }&sign_type=RSA&sign=#{signed_option_string}"
  end

  def generate_md5_sign(options, key=Settings["md5_key"])
    Rails.logger.info("-----md5key: #{key} -------------")
    key_str = sort_options_to_str(options)
    key_str = key_str + key
    #puts key_str
    Digest::MD5.hexdigest(key_str)
  end

  def sort_options_to_str(options)
    options.sort.map{|k,v| "#{k}=#{v}"}.join("&")
  end

  def options_to_str(options)
    options.map{|k,v| "#{k}=#{v}"}.join("&")
  end

  def wap_notify_params_to_str(params)
    params_array = params.to_a
    if params["sec_id"]
      params_array[1], params_array[2] = params_array[2], params_array[1]
    end
    params_array.map{|k,v| "#{k}=#{v}"}.join("&")
  end

  #RSA签名
  def rsa_sign(for_sign_string, pri_key = Settings["rsa_pri_key"])
    #转换为openssl密钥
    openssl_key = OpenSSL::PKey::RSA.new(pri_key)
    #使用openssl方法进行sha1签名digest(不能用sha256)
    digest = OpenSSL::Digest::SHA1.new
    signature = openssl_key.sign digest, for_sign_string
    #base64编码
    Base64.encode64(signature).gsub("\n", "")
  end

  # 验证RSA签名
  def rsa_verify?(for_sign_string, signed_string, pub_key = Settings["alipay_rsa_pub_key"])
    # 创建RSA对象
    puts pub_key
    pub_key = pub_key.is_a?(String) ? Base64.decode64(pub_key) : pub_key
    openssl_public = OpenSSL::PKey::RSA.new(pub_key)
    # 生成SHA1秘钥串
    digest = OpenSSL::Digest::SHA1.new
    # 验证签名
    openssl_public.verify(digest, Base64.decode64(signed_string), for_sign_string)
  end

  def pri_key_file
    File.read("#{Rails.root}/config/certs/rsa_private_key.pem")
  end

  def pri_app_key_file
    File.read("#{Rails.root}/config/certs/app_private_key.pem")
  end

  def pub_key_file
    File.open("#{Rails.root}/config/certs/alipay_public_key.pem")
  end

  def params_valid?(params)
    sign = params.delete("sign")
    sign_type = params["sec_id"] || params.delete("sign_type")
    if sign_type.upcase == "RSA"
      key_str = sort_options_to_str(params)
      rsa_verify?(key_str, sign)
    else
      sign == generate_md5_sign(params, Settings["PC_md5_key"])
    end
  end

  def wap_params_valid?(params, settings=Settings)
    sign = params.delete("sign")
    sign_type = params.delete("sign_type")
    key_str = wap_notify_params_to_str(params)
    key_str = key_str + settings["md5_key"]
    sign == Digest::MD5.hexdigest(key_str)
  end

  def get_ip
    request.env["HTTP_X_FORWARDED_FOR"] || request.remote_ip
  end

  def alipay_pay_url(order, notify_url = alipay_notify_url, return_url = alipay_return_url, settings=Settings)
    url = settings["mapi_url"]
    "#{url}?#{create_direct_pay_by_user(order, notify_url, return_url).to_query}"
  end
end
