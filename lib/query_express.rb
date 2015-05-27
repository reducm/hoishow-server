module QueryExpress
  def get_express_info(code)
    url = "http://syt.sf-express.com/css/newmobile/queryBillInfo.action?delivery_id=#{code}"

    JSON.parse(RestClient.get url)
  end
end