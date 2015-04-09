# 基础参数，错误返回码
1. 所有api请求时，需带渠道参数`key`, `key`由后台工作人员配置获取
2. 所有api请求时，url后需要带`.json`
3. api成功返回时参照各api描述，失败时统一返回:`{errors: "..."}`, 状态403


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
## 关注明星或演唱会
[/api/v1/users/follow_subject]()

type: `POST`

必需参数 `{api_token: "users_token", mobile: "users mobile", subject_type: "Star或Concert, 注意大写", subject_id: "star_id或concert_id"}`

成功时返回{msg: "ok"}, 状态200

--------
## 取消关注明星或演唱会
[/api/v1/users/unfollow_subject]()

type: `POST`

必需参数 `{api_token: "users_token", mobile: "users mobile", subject_type: "Star或Concert, 注意大写", subject_id: "star_id或concert_id"}`

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
  [{
    id: "123",
    name: "汪峰",
    avatar: "http://www.xxx/1.jpg",
    is_followed: true
  }...]
```

-------
## 用户关注的演唱会
[/api/v1/users/followed_concerts]()

type: `POST`

必需参数 `{api_token: "users_token", mobile: "users mobile"}`

成功时返回：
```javascript
  {
    concerts: [
      {
        is_followed: true
        is_vote: false //如果传用户信息，将会返回用户是否投票了该演唱会，否则统一为false
        参照concert对象参数
      }
    ]
  }
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
    city_id: "" //当subject_type是Concert时，必须传city_id
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
    area_id: area的id, 
    quantity: 3 //购买数量
  }
```

成功时返回
```javascript
  Order对象
```

-----------


