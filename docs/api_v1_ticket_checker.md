# 基础参数，错误返回码
1. 所有api请求时，url后需要带`.json`
2. api成功返回时参照各api描述，失败时统一返回:`{errors: "..."}`, 状态403

# 验票客户端

## 登陆
[/api/v1/admins/sign_in]()

type: `POST`

必需参数

```javascript
  {
    name: "吴彦祖",
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
    last_sign_in_at: "201504102140270000"
  }
```

-----

## 验票
[/api/v1/admins/check_ticket]()

type: `PATCH`

必需参数

```javascript
  {
    codes: ["票码",...], //勾选门票或人工输入票码 
    admin_id: "2", //验票员id
  }
```

成功时返回: `{msg: "ok"}` 返回状态码200或201
