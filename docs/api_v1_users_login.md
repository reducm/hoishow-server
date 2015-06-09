# 基础参数，错误返回码
1. 所有api请求时，需带渠道参数`key`, `key`由后台工作人员配置获取
2. 所有api请求时，url后需要带`.json`
3. api成功返回时参照各api描述，失败时统一返回:`{errors: "..."}`, 状态403
4. 如返回406就强制让用户下线


# 用户信息相关API

## 手机验证接口
[/api/v1/users/verification]()

type: `POST`

除了正式环境会发短信外，其他测试环境一律生成123456验证码

所需参数

```javascript
  {
    mobile: "13622232323"
  }
```

成功时返回: `{msg: "ok"}` 返回状态码200或201


-----

## 登陆

[/api/v1/users/sign_in]()

type: `POST`

所需参数

```
  {
    mobile: "13512310293",
    code: "123456" //短信验证码
  }
```

成功时返回:

```javascript
  {
  参考“用户对象”
  }
```


-----

## 获取用户信息

[/api/v1/users/get_user]()

type: `POST`

所需参数

```
  {
    mobile: "13512310293",
    api_token: "ASDKAJSDKASJDLAKSD"
  }
```

成功时返回:

```javascript
  {
  参考“用户对象”
  }
```

-----

## 更新用户信息接口
[/api/v1/users/update_user]()

type: `POST`

必需参数 `{api_token: "users_token", mobile: "users mobile", type: "有avatar, nickname, sex, birthday4种取值""}`

选择参数

当type是avatar时, 必须有{avatar: 头像文件}

当type是nickname时, 必须有{nickname: "用户名称"}

当type是sex时, 必须有{sex: "性别类型, 取值male femalef secret"与返回数据统一}

当type是birthday时, 必须有{birthday: "时间戳"}


成功时返回
```javascript
  {
  参考“用户对象”
  }
```
--------
## 关注明星或演唱会或演出
[/api/v1/users/follow_subject]()

type: `POST`

必需参数 `{api_token: "users_token", mobile: "users mobile", subject_type: "Star或Concert或Show, 注意大写", subject_id: "star_id或concert_id或show_id"}`

成功时返回{msg: "ok"}, 状态200

--------
## 取消关注明星或演唱会或演出
[/api/v1/users/unfollow_subject]()

type: `POST`

必需参数 `{api_token: "users_token", mobile: "users mobile", subject_type: "Star或Concert或Show, 注意大写", subject_id: "star_id或concert_id或show_id"}`

成功时返回{msg: "ok"}, 状态200

--------

## 创建评论
[/api/v1/users/create_comment]()

type: `POST`

可选参数 `{parent_id: "comment.parent_id"//对某一个评论所作出的评论，默认为nil}`

必需参数 `{api_token: "users_token", mobile: "users mobile", topic_id: Topic的id, content: "评论的内容"}`

成功时返回{Comment对象}, 状态200

--------


## 对演唱会投票
[/api/v1/users/vote_concert]()

type: `POST`

必需参数 `{api_token: "users_token", mobile: "users mobile", concert_id: "Concertid", city_id: "Cityid"}`

成功时返回{msg: "ok"}, 状态200

-------
## 用户关注的明星
[/api/v1/users/followed_stars]()


type: `POST`

必需参数 `{api_token: "users_token", mobile: "users mobile"}`

成功时返回：
```javascript
  [star对象列表]
```

-------
## 用户关注的演唱会
[/api/v1/users/followed_concerts]()

type: `POST`

必需参数 `{api_token: "users_token", mobile: "users mobile"}`

成功时返回：
```javascript
   [concert对象列表]
```

----------
## 用户关注的演出
[/api/v1/users/followed_shows]()

type: `POST`

必需参数 `{api_token: "users_token", mobile: "users mobile"}`

成功时返回：
```javascript
  [show对象列表]
```

----------

## 用户创建互动Topic, 包括明星Star互动、Concert演唱会互动
[/api/v1/users/create_topic]()

type `POST`

必需参数
```javascript
  {
    api_token: "users_token",
    mobile: "users mobile",
    subject_type: "Star or Concert", //创建互动的是明星或演唱会
    subject_id: "star_id or concert_id", //具体的明星id或者演唱会id
    content: "内容",
    city_id: "" //当subject_type是Concert时，可以传city_id
  }
```

成功时返回
```javascript
  Topic对象
```

----------
## 用户创建Order
[/api/v1/users/create_order]()

type `POST`

必需参数
```javascript
  {
    api_token: "users_token",
    mobile: "users mobile",
    show_id: "Show的id",

    //只能选区
    area_id: area的id,
    quantity: 3 //购买数量

    //可以选座
    areas:
     [
      area_id: 1 //区域id,
      seats:
       [
         row: 1,   //行号
         column: 1 //列号
       ]
     ]
  }
```

成功时返回
```javascript
  Order对象
```

-----------


## 用户更新快递信息
[/api/v1/users/update_express_info]()

type `POST`

必需参数
```javascript
  {
    api_token: "users_token",
    mobile: "users mobile",
    out_id: order的out_id,
    express_id: 用户地址的id,
    user_name: "收货人名字",
    user_mobile: "收货人的电话",
    user_address: "收货人地址(除了省,市,区之外的地址)",
    province: "收货地址的省",
    city: "收货地址的市",
    district: "收货地址的区",
  }
```

成功时返回{msg: "ok"}, 状态200

-----------

## 支付订单
[/api/v1/orders/:out_id/pay]()

type `POST`

必需参数
```javascript
  {
    api_token: "users_token",
    mobile: "users mobile",
    payment_type: "alipay/wxpay"
  }
```

成功时返回
```javascript
  {
    order: {order对象}
    payment: 'alipay',             #支付类型
    query_string: 'query_string'   #支付宝签名
  }

  {
    order: {order对象},
    payment: 'wxpay',              #支付类型
    sign: {
      "appid": "wxda8a21cdffd0d0ab",
      "noncestr": "1428047547",
      "package": "Sign=WXpay",
      "partnerid": "1231629801",
      "prepayid": "12010000001504039efa4a89df23e72a",
      "timestamp": "1428047547",
      "sign": "7039090da18606333d3458a0c3746360ed6ba048"
    }
  }
```


-----------

## 查看我的订单列表
[/api/v1/orders]()

type `GET`

必需参数
```javascript
  {
    api_token: "users_token",
    mobile: "users mobile",
  }
```

可选参数
```javascript
{
  page: 1
}
```


成功时返回
```javascript
   [order对象列表]
```


-----------

## 查看订单详情
[/api/v1/orders/:out_id]()

type `GET`

必需参数
```javascript
  url携带order out_id参数
  {
    api_token: "users_token",
    mobile: "users mobile",
  }
```

成功时返回
```javascript
  Order对象
```
-----------

## 查看消息列表
[/api/v1/messages]()

type `GET`

必需参数
```javascript
  {
    api_token: "users_token",
    mobile: "users mobile",
    type: "all/system/reply",   #系统消息或者是回复的消息
  }
```

若type参数是system或reply，成功时返回
```javascript
  Message对象
```

若type参数是all，成功时根据有无新消息返回不同msg
有新消息`{msg: "yes"}` 返回状态码200
没有新消息`{msg: "no"}` 返回状态码200
