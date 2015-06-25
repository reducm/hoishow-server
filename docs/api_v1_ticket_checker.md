# 基础参数，错误返回码
1. 所有api请求时，url后需要带`.json`
2. api成功返回时参照各api描述，失败时统一返回:`{errors: "..."}`, 状态403
4. 如返回406就强制让用户下线

# 验票客户端

## 登陆
[/api/v1/admins/sign_in]()

type: `POST`

必需参数

```javascript
  {
    name: "吴彦祖", //验票员账户
    password: "123456"
  }
```

成功时返回Admin对象:

```javascript
  {
    id: "2",
    name: "吴彦祖",
    admin_type: "ticket_checker", //验票员
    email: "xxx@ooo.com" or "", //没有email返回空字符串
    last_sign_in_at: "201504102140270000",
    api_token: "ASDKAJSDKASJDLAKSD"
  }
```

-----

## 获取订单详情
[/api/v1/orders/:out_id/show_for_qr_scan]()

type: `GET`

必须参数 Order的out_id在url传

```javascript
  {
    name: "吴彦祖", //验票员账户
    api_token: "ASDKAJSDKASJDLAKSD"
  }

```

成功时返回Order对象:
```javascript
  {参考Order对象}
```

----

## 获取门票详情
[/api/v1/tickets/get_ticket]()

type: `GET`

```javascript
  {
    name: "吴彦祖", //验票员账户
    api_token: "ASDKAJSDKASJDLAKSD",
    code: "票码"
  }

```

成功时返回Ticket对象:
```javascript
  {参考Ticket对象}
```

----

## 验票
[/api/v1/tickets/check_tickets]()

type: `PATCH`

必需参数

```javascript
  {
    codes: ["票码",...], //勾选门票或人工输入票码 
    name: "吴彦祖", //验票员账户
    api_token: "ASDKAJSDKASJDLAKSD"
  }
```

成功时返回: `{msg: "ok"}` 返回状态码200或201
