API V1 不需登录

#基础参数，错误返回码
1. 所有api请求时，url后需要带`.json`
2. api成功返回时参照各api描述，失败时统一返回:`{errors: "..."}`, 状态403

--------
##明星列表
[/api/v1/stars]()

type: `GET`

可选参数
```javascript
  {
    mobile: "13512310293",
    code: "123456" //短信验证码
  }
```

成功时返回：
```javascript
  [{
    id: "123",
    name: "汪峰",
    avatar: "http://www.xxx/1.jpg",
    is_followed: false //如果传用户信息，将会返回用户是否关注该明星，否则统一为false
  }...]
```

----
##明星详情
[/api/v1/stars/:id]()

type: `GET`

可选参数
```javascript
  {
    mobile: "13512310293",
    code: "123456" //短信验证码
  }
```

成功时返回：
```javascript
  {
    id: "123",
    name: "汪峰",
    avatar: "http://www.xxx/1.jpg",  
    is_followed: false //如果传用户信息，将会返回用户是否关注该明星，否则统一为false
    videos: [{参照video对象},...],
    concerts: [{参照concert对象},...],
    shows: [{参照show对象},...],
    comments: [{参照comment对象},...],
  }
```

-------------

##演唱会列表
[/api/v1/concerts]()

type: `GET`

可选参数
```javascript
  {
    mobile: "13512310293",
    code: "123456" //短信验证码
  }
```

成功时返回：
```javascript
  {
    page: 1,
    per: 20,
    concerts: [
      {
        is_followed: false //如果传用户信息，将会返回用户是否关注该演唱会，否则统一为false
        参照concert对象参数
      }
    ]
  }
```

----
#对象查询

##Star对象

##Concert对象
```javascript
{
  id: concert_id,
  name: "Concert名称",
  description: "介绍",
  start_date: "众筹开始时间",
  end_date: "众筹结束时间"
  poster: "海报url",
  followers_count: "关注数",
  comments_count: "评论数",
  shows_count: "演唱会数目"
}
```

##Show对象
```javascript
{
  id: show_id,
  name: "Show名称",
  show_time: "开show时间",
  poster: "海报url",
  concert: {concert对象},
  city: {city对象}
  stadium: {stadium对象}
}
```

##Comment对象
```javascript
{
  id: coment_id,
  subuject_type: "评论对象，可以是star或者concert",
  subject_id: "评论对象id",
  content: "评论",
  user: {:id, :nickname, :avatar},
}
```