# Hoishow接口规范
## 版本号 V1

-----------------------------------

## 基础参数，错误返回码
1. 所有api请求时，url后需要带api_key, timestamp, sign, [查看签名生成方法](#生成签名)

2. api成功返回时参照各api描述，失败时对照错误代码

-----------------------------------

###城市列表
[/api/open/v1/cities]()

type `GET`

description: 获取全部的城市

成功时返回

```javascript
  {
    result_code: 0,
    data:
    [{
      id: 1, //城市id
      name: 1, //城市名称
    },.....]
  }
```

-----------------------------------

###场馆列表
[/api/open/v1/stadiums]()

type `GET`

description: 获取全部的场馆

成功时返回

```javascript
  {
    result_code: 0,
    data:
    [{
     id: 1, //场馆id
     name: '首都体育馆', //场馆名称
     address: '首都体育馆', //场馆地址
     longitude: '111.111', //场馆经度
     latitude: '222,222', //场馆纬度
     city_id: 1, //城市id
    },.....]
```

-----------------------------------

###演出列表
[/api/open/v1/shows]()

type `GET`

description: 获取全部的演出

成功时返回

```javascript
  {
    result_code: 0,
    data:
    [{
      id:  //show_id,
      name:  //Show名称,
      city_id:  //city_id,
      city_name: //city名称,
      stadium_id:  //stadium_id,
      stadium_name: //stadium名称,
      show_time:  //开show时间,
      poster:  //海报url,
      ticket_pic:  //门票图片url,
      description:  //图文介绍,
      description_time:  //当show的status为going_to_open时显示这个时间替代show_time,
      is_top: "true or false" //是否置顶,
      status:  // selling(售票中)/sell_stop(售票结束)/going_to_open(即将开放),
      ticket_type:  // e_ticket(电子票)/r_ticket(实体票),
      stadium_map: 'xxx' //场馆图
      seat_type: // selectable(可以选座)/selected(只能选区)
      mode:  // voted_users(投票用户购买)/all_users(所有用户购买)
      stars: "陈奕迅 | 张敬轩",
      price_range: '1 - 100'
    },.....]
```

-----------------------------------

###区域列表
[/api/open/v1/areas]()

type `GET`

description: 获取全部的区域

必须参数
```javascript
  {
    show_id: 1
  }
```

成功时返回

```javascript
  {
    result_code: 0,
    data:
    [{
      id: 1, //area对象的id
      name: "A区", //区域名称
      seats_count: 11, //座位数
      show_id: 1 //演出id
      event_id: 1 //场次id
      stadium_id: 22, //场馆id
      price: 1,  //票价
      seats_left: 10,  //剩余票数
      is_sold_out: false   //是否卖完
     },.....]
```

-----------------------------------

###场馆信息查询
[/api/open/v1/stadiums/:id]()

type `GET`

description: 获取指定场馆的详情

成功时返回

```javascript
  {
    result_code: 0,
    data:
    {
      id: 1, //场馆id
      name: '首都体育馆', //场馆名称
      address: '首都体育馆', //场馆地址
      longitude: '111.111', //场馆经度
      latitude: '222,222', //场馆纬度
      city_id: 1, //城市id
    }
  }
```

-----------------------------------

###演出信息查询
[/api/open/v1/shows/:id]()

type `GET`

description: 获取指定演出的详情

成功时返回

```javascript
  {
    result_code: 0,
    data:
    {
      id:  //show_id,
      name:  //Show名称,
      concert_name:  //concert名称,
      city_id:  //city_id,
      city_name: //city名称,
      stadium_id:  //stadium_id,
      stadium_name: //stadium名称,
      show_time:  //开show时间,
      poster:  //海报url,
      ticket_pic:  //门票图片url,
      description:  //图文介绍,
      description_time:  //当show的status为going_to_open时显示这个时间替代show_time,
      is_top: "true or false" //是否置顶,
      status:  // selling(售票中)/sell_stop(售票结束)/going_to_open(即将开放),
      ticket_type:  // e_ticket(电子票)/r_ticket(实体票),
      stadium_map: 'xxx' //场馆图
      seat_type: // selectable(可以选座)/selected(只能选区)
      mode:  // voted_users(投票用户购买)/all_users(所有用户购买)
      star: "陈奕迅 | 张敬轩",
      price_range: '1 - 100'
    }
  }
```

-----------------------------------

###区域信息查询
[/api/open/v1/areas/:id]()

type `GET`

description: 获取指定区域的详情

必须参数
```javascript
  {
    show_id: 1
  }
```

成功时返回

```javascript
  {
    result_code: 0,
    data:
    {
      id: 1, //area对象的id
      name: "A区", //区域名称
      seats_count: 11, //座位数
      show_id: 1 //演出id
      stadium_id: 22, //场馆id
      price: 1,  //票价
      seats_left: 10,  //剩余票数
      is_sold_out: false   //是否卖完
    }
  }
```

-----------------------------------
###场次列表
[/api/open/v1/events]

type `GET`

description: 根据show_id获取全部场次信息

必须参数
```javascript
  {
    show_id: 1 //演出id
  }
```

成功时返回
```javascript
  {
    result_code: 0,
    data: [
      {
        id: 1, //event对象的id
        show_id: 1, //演出id
        show_time: '201504102140270000' //show场次的时间
      },......
    ]
  }
```


-----------------------------------
###区域座位信息
[/api/open/v1/areas/:id/seats_info]

type `GET`

description: 区域的所有座位信息

必须参数
```javascript
  {
    show_id: 1, //演出id
  }
```

成功时返回
```javascript
  {
    result_code: 0,
    data: [
      {
        id: 1, //座位id
        row: 1, //行号
        column: 1, //列号
        name: '1排1座', //座位号
        price: 1, //价格
        status: 'avaliable' //座位状态
      },......
    ]
  }
```

-----------------------------------

###座位信息查询
[/api/open/v1/query_seats]()

type `GET`

description: 根据ID查询座位信息

必须参数

```javascript
  {
    seat_ids: ['1', '2', '3'] //要查询的座位ID
  }
```

成功时返回
```javascript
  {
    result_code: 0,
    data: [
      {
        id: 1, //座位id
        row: 1, //行号
        column: 1, //列号
        name: '1排1座', //座位号
        price: 1, //价格
        status: 'avaliable' //座位状态
      },......
    ]
  }
```

-----------------------------------

###订单查询
[/api/open/v1/orders/:out_id]()

type `GET`

description: 查询订单最新信息

必须参数

```javascript
  {
    bike_user_id: 1, //渠道用户id
    mobile: '13333333333', //用户手机号
  }
```

成功时返回

```javascript
  {
    result_code: 0,
    data:
    {
      out_id: 123,
      amount: 99.9,
      stadium_id: 123, //场馆id
      stadium_name: "场馆名字",
      show_name: "演出名字",
      show_id: 123, //演出id
      city_name: "城市名字",
      city_id: 123, //城市id
      express_code: "97698906987", //快递单号
      express_id: 123, //用户最新的地址id
      user_name: "tom", //收货人姓名
      user_mobile: "11012013099", //收货人电话
      order_address: "订单完整地址"
      status: "pending" or "paid" or "success" or "refund"or "outdate", //分别表示“未支付”，“已支付”，“已出票”，“退款”，“过期”
      tickets_count: //票数
      ticket_type:  // e_ticket(电子票)/r_ticket(实体票),
      ticketed_at:  // 出票时间,
      show_time: '201504102140270000' //show的演出时间
      tickets:
      [{
        id: 11, //ticket的id
        area_name: 'A区', //区域名称
        price: 99.00, //价格
        code: 'xasxasasxa', //票码
        seat_name: '1排1座', //座位名称
        status: "pending" or "success" or "used" //未支付，没有code
       },...]
    }
  }
```

-----------------------------------

###查询票量
[/api/open/v1/orders/check_inventory]()

type `GET`

description: 查询票务库存

必须参数

```javascript
  {
    show_id: 1, //演出id

    #选区
    area_id: 1, //区域id
    quantity: 1, //数量

    #选座
    seats: [1,2,3,4] //座位id
  }
```

成功时返回

```javascript
  {message: 'ok'}
```

选座时座位有被占用的返回

```javascript
  {
    result_code: 2004,
    message: 'x排x座已被锁定',
  }
```

-----------------------------------

###订单锁座
[/api/open/v1/orders]()

type `POST`

description: 创建订单并锁座

必须参数

```javascript
  {
    show_id: 1, //演出id
    bike_user_id: 1, //渠道用户id
    mobile: '13333333333', //用户手机号
    bike_out_id: '123' //渠道订单号
    buy_origin: 'ios' //下单平台

    #选区
    area_id: 1, //区域id
    quantity: 1, //数量

    #选座
    areas:
    [
      {
        area_id: 1, //区域id
        seats:
        [{
          id: 1 //座位id
        },....]
      }
    ]
  }
```

成功时返回

```javascript
  {同订单详情}
```

-----------------------------------
###订单确认
[/api/open/v1/orders/:out_id/confirm]()

type `POST`

description: 订单支付成功确认出票

必须参数

```javascript
  {
    bike_user_id: 1, //渠道用户id
    mobile: '13333333333' //用户手机号
  }
```

可选参数 //实体票需要更新收货信息

```javascript
  {
    user_name: 1, //收货人
    user_mobile: '13333333333' //收货人电话
    address: '广东省 广州市 海珠区 新港东路2433号'
  }
```

成功时返回

```javascript
  {同订单详情}
```

-----------------------------------
###订单取消
[/api/open/v1/orders/:out_id/cancel_order]()

type `POST`

description: 取消订单

必须参数

```javascript
  {
    mobile: '13333333333' //用户手机号
  }
```

成功时返回

```javascript
  {message: 'ok'}
```

订单取消失败时的返回

```javascript
  {
    result_code: 3017,
    message: '订单取消失败',
  }
```


----

##其他

----

###<a name="生成签名"></a>生成签名

sign生成方法:

1 将所有参数排序

2 拼接成字符串

3 尾部加上secretcode进行MD5加密

4 加密后转成大写

例如获取城市列表:

GET http://服务器地址/api/open/v1/cities.json?api_key=FTpDcdRQj3WRUKny8QxEpw&timestamp=1438594945&sign=426B9D7335EB24D8541AB2ACD4BA914F

----

###返回码列表

- 成功
  + 0 成功
- 验证
  + 1001 商户信息不存在
  + 1002 签名验证不通过
  + 1003 缺少必要的参数
  + 1004 请求因超时而失效
- 数据
  + 2001 数据错误: 如查询数据不存在
  + 2002 演出未开发购票
  + 2003 座位数量限制
  + 2004 座位已被占
- 订单
  + 3001 下单锁座失败
  + 3002 演出信息无效
  + 3003 价格验证失败
  + 3004 找不到该用户
  + 3005 手机号不正确
  + 3006 订单不存在
  + 3007 订单已支付不能取消
  + 3008 订单解锁失败
  + 3009 订单金额未支付
  + 3010 请求座位失败
  + 3011 解锁原因错误
  + 3012 订单确认失败
  + 3014 缺少 areas 参数
  + 3015 你所买的区域的票已经卖完了！
  + 3016 重复创建订单
  + 3017 订单取消失败
