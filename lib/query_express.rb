module QueryExpress
  USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:41.0) Gecko/20100101 Firefox/41.0'
  COMPANY = [
      {"companyname"=>"申通快递","code"=>"shentong"},
      {"companyname"=>"EMS","code"=>"ems"},
      {"companyname"=>"顺丰速运","code"=>"shunfeng"},
      {"companyname"=>"韵达快递","code"=>"yunda"},
      {"companyname"=>"圆通速递","code"=>"yuantong"},
      {"companyname"=>"中通速递","code"=>"zhongtong"},
      {"companyname"=>"汇通快运","code"=>"huitongkuaidi"},
      {"companyname"=>"天天快递","code"=>"tiantian"},
      {"companyname"=>"宅急送","code"=>"zhaijisong"},
      {"companyname"=>"速尔快递","code"=>"suer"},
      {"companyname"=>"广东邮政","code"=>"guangdongyouzhengwuliu"},
      {"companyname"=>"中邮物流","code"=>"zhongyouwuliu"},
      {"companyname"=>"包裹/平邮","code"=>"youzhengguonei"},
      {"companyname"=>"快捷速递","code"=>"kuaijiesudi"},
      {"companyname"=>"中铁快运","code"=>"zhongtiewuliu"},
      {"companyname"=>"联邦快递","code"=>"lianbangkuaidi"},
      {"companyname"=>"飞快达","code"=>"feikuaida"},
      {"companyname"=>"全峰快递","code"=>"quanfengkuaidi"},
      {"companyname"=>"如风达","code"=>"rufengda"},
      {"companyname"=>"芝麻开门","code"=>"zhimakaimen"}
    ]

  def json_open(io_or_uri)
    if io_or_uri.is_a? String
      opts = io_or_uri =~ /^http/ ? { "User-Agent" => USER_AGENT, "Referer" => "http://www.kuaidi100.com" } : { }
      io = open( io_or_uri, opts)
    else
      io = io_or_uri
    end
    JSON.parse(io.read.force_encoding('utf-8'), :symbolize_names => true)
  end

  def company_code(express_no)
    url = "http://www.kuaidi100.com/autonumber/auto?num=#{express_no}"
    res = json_open(url)
    res = res.sort_by{|i| i[:noCount] }
    res.empty? ? nil : res.last[:comCode]
  end

  def decode_company(code)
    if com = COMPANY.find{|i| i['code'] == code}
      return com['companyname']
    end
    code
  end

  def get_express_info(express_no, com_code=nil)
    com_code ||= company_code(express_no)
    return nil unless com_code
    url = "http://www.kuaidi100.com/query?type=#{com_code}&postid=#{express_no}&id=1&valicode=&temp=0.08001715072286408"
    result = json_open(url)

    begin
      {
        status: 'success',
        delivery_id: result[:nu],
        delivery_company: decode_company(result[:com]),
        data: result[:data].map do |route|
                {
                  time: Time.parse(route[:time]).to_ms,
                  message: route[:context]
                }
              end
      }
    rescue
      nil
    end
  end
end
