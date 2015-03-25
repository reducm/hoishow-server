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

必需参数 `{api_token: "users_token", mobile: "users mobile", subject_type: "Star或Concert, 注意大写", subject_id: "star_id或concert_id"}`

成功时返回{msg: "ok"}, 状态200

-------

# 用户对象

```javascript
  {
      api_token: api_token, 
      api_expires_in: "距离当前还有多少秒过期", 
      mobile: "13632323232", 
      avatar: "http://www.xxx/1.jpg",  //用户头像
      nickname: "李枝江",
      sex: "male", //"male"表示男性， "female"表示女性， "secret"表示保密
      birthday: "32872394934" //时间戳
    }
```
-----