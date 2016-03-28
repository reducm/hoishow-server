module YongleService
  module Service
    extend YongleService::Logger
    extend self

    ACTIONS = {
      get_all_fconfig: {action: 'getAllFconfig', url: '/unionOrder/getAllFconfig'},   #查询所有分站
      all_category: {action: 'allCategory', url: '/unionOrder/allCategory'},   #查询所有商品分类
      get_venue_info: {action: 'getVenueInfo', url: '/unionOrder/getVenueInfo'},  #根据场馆id查询场馆信息
      find_product_info: {action: 'findProductInfo', url: '/unionOrder/findProductInfo'},   #查询商品状态信息
      find_productprice_info: {action: 'findProductpriceInfo', url: '/unionOrder/findProductpriceInfo'},   #获取商品票价信息
      get_product: {action: 'getProduct', url: '/unionOrder/getProduct'},   #获取单个商品更新信息
      get_recommend_product_info: {action: 'getRecommendProductInfo', url: '/unionOrder/getRecommendProductInfo'},   #查询重磅推荐、新品上架、即将上演、编辑精选的商品id
      find_order_by_unionid_and_orderid: {action: 'findOrderByUnionidAndOrderid', url: '/unionOrder/findOrderByUnionidAndOrderid'},   #根据联盟id和联盟订单id查询订单信息
      get_order_list: {action: 'getOrderList', url: '/unionOrder/getOrderList'},   #根据联盟id和联盟订单id查询查询订单信息
      update_pay_status: {action: 'updatePayStatus', url: '/unionOrder/updatePayStatus'},   #联盟方订单支付成功后更新支付状态
      online_order: {action: 'onlineOrder_v2', url: '/unionOrder/onlineOrder_v2'},   #在线订票接口
      online_seat_order: {action: 'onlineSeatOrder_v2', url: '/unionSeatOrder/onlineOrder_v2'},   #在线选座订票接口
      calculate_total: {action: 'calculateTotal', url: '/unionSeatOrder/calculateTotal'}   #在线选座订票查询应收金额接口
    }

    def get_all_fconfig
      options = {unionId: unionId}
      parse_fetch_data(ACTIONS[__method__], options)
    end

    def all_category
      parse_fetch_data(ACTIONS[__method__])
    end

    def get_city_data(city_code)
      str = {action: '', url: "/upload/DataXml/#{unionId}/#{city_code}.xml"}
      parse_fetch_data(str)
    end

    def get_venue_info(venue_id)
      options = {unionId: unionId, venueId: venue_id}
      parse_fetch_data(ACTIONS[__method__], options)
    end

    def find_product_info(product_id)
      options = {unionId: unionId, productId: product_id}
      parse_fetch_data(ACTIONS[__method__], options)
    end

    def find_productprice_info(product_play_id)
      options = {unionId: unionId, productPlayid: product_play_id}
      parse_fetch_data(ACTIONS[__method__], options)
    end

    def get_product(product_id)
      options = {unionId: unionId, productId: product_id}
      parse_fetch_data(ACTIONS[__method__], options)
    end

    def get_recommend_product_info(fconfig_id)
      options = {unionId: unionId, fconfigId: fconfig_id}
      parse_fetch_data(ACTIONS[__method__], options)
    end

    def find_order_by_unionid_and_orderid(order_id)
      options = {unionId: unionId, unionOrderId: order_id}
      parse_fetch_data(ACTIONS[__method__], options)
    end

    def get_order_list(options)
      options.merge!(unionId: unionId)
      parse_fetch_data(ACTIONS[__method__], options)
    end

    def update_pay_status(order_id)
      str = Digest::MD5.hexdigest "#{YongleSetting['key']}#{order_id}"
      options = {unionId: unionId, unionOrderId: order_id, encryptStr: str}
      parse_fetch_data(ACTIONS[__method__], options)
    end

    def online_order(options) #暂时只有选区下单没有选座
      createTime = options[:onlineOrderReq].delete(:created_at).strftime('%Y-%m-%d %T')
      sign = Digest::MD5.hexdigest "#{YongleSetting['key']}#{createTime}"
      options[:onlineOrderReq].merge!(
      {
        unionId: unionId,
        identifyingCode: sign,
        createTime: createTime
      })
      parse_fetch_data(ACTIONS[__method__], options.to_xml(root: 'Request', skip_types: true, dasherize: false), :post)
    end

    def parse_fetch_data(query_info, options={}, method=:get)
      url = "#{YongleSetting['base_url']}#{query_info[:url]}"
      begin
        request_options = {
          method: method,
          url: url,
          #timeout: 10,
          headers: {
            action: query_info[:action]
          }
        }

        if method == :get
          request_options[:headers].merge!(params: options)
        elsif method == :post
          request_options.merge!(payload: options)
        end
        yongle_logger.info options
        response = RestClient::Request.execute(request_options)
        trade_data = Hash.from_xml(response)
        result = :result_code.in?(response.headers) ? response.headers : {result_code: '1000', result_info: '成功'}
        wrap_result(result, trade_data)
      rescue => e
        yongle_logger.info "result: 500, message: #{e.message}"
        wrap_result({result_code: '500', result_info: e.message})
      end
    end

    def unionId
      @unionId ||= YongleSetting['unionId']
    end

    def wrap_result(result, data=nil)
      {
        "result" => result[:result_code],
        "message" => CGI.parse(result[:result_info]).keys.first,
        "data" => data
      }
    end
  end
end
