# API V1 不需登录

## 基础参数，错误返回码
1. 所有api请求时，url后需要带`.json`
2. api成功返回时参照各api描述，失败时统一返回:`{errors: "..."}`, 状态403

--------
## 明星列表
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

--------
## 搜索明星
[/api/v1/stars/search]()

type: `GET`

必选参数
```javascript
  {
    q: "查询关键字"
  }
```

成功时返回：
```javascript
  [{
    id: "123",
    name: "汪峰",
    avatar: "http://www.xxx/1.jpg",
  }...]
```

----

## 明星详情
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

## 演唱会和演出列表
[/api/v1/concerts/]()

type: `GET`

可选参数
```javascript
  {
    mobile: "13512310293",
    code: "123456" //短信验证码
    page: "2" //页码
  }
```

成功时返回：
```javascript
  [
    {
      参照concert对象参数
      is_followed: false //如果传用户信息，将会返回用户是否关注该演唱会，否则统一为false
      is_vote: false //如果传用户信息，将会返回用户是否投票了该演唱会，否则统一为false
    }
  ]
```

----
## 演唱会详情
[/api/v1/concerts/:id]()

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
    is_followed: false //如果传用户信息，将会返回用户是否关注该演唱会，否则统一为false
    is_voted: false //如果传用户信息，将会返回用户是否投票该演唱会，否则统一为false
    cities: [{参照city对象}],
    stars: [{参照star对象}],
    shows: [{参照show对象},...],
    comments: [{参照comment对象},...],
    city_rank: [{参照city_rank接口返回的结构}]
  }
```

-----------
## Concert城市投票排名
[/api/v1/concerts/:id/city_rank]()

type: `GET`

成功时返回：
```javascript
  //按照投票数的由高到低排序
  [{
    City对象,
    vote_count: 投票数
  }]
```

-------
## 演出列表

[/api/v1/shows/]()

type: `GET`

成功时返回
```javascript
  {
    shows: [
      {
        参照show对象参数
      }
    ]
  }
```



----
## 演出详情
[/api/v1/shows/:id]()

type: `GET`

成功时返回：
```javascript
  {
    id: "123"
    name: "演出名称"
    min_price: "100"
    max_price: "1000"
    concert_id: "123", //从属演唱会id
    city_id: "123", //从属城市id
    stadium_id: "123", //从属场馆id
    show_time: "201504081428370800"
    poster: "http://xx.jpg"
    concert: {参考concert对象}
    city: {参考city对象}
    stadium: {参考stadium对象}
    topics: [ {参考topic对象} ]
  }
```

----

## 买票、选区接口

[/api/v1/shows/:id/preorder]()

type `GET`

必需参数 
```javascript
  //show的id在url里传递
```

成功时返回
```javascript
{
  stadium: {
    Stadium对象Key/Value,
    areas: [{ //Area价格由低到高排序
      id: area_id,
      name: 区名,
      seats_count: 座位总数,
      seats_left: 座位剩余,  
      is_sold_out: 是否售完true or false，
      price: 该场show在此区域的售价, float类型,
    }....]
  },
  show: {Show对象}
}
```

------------

## 话题详情
[/api/v1/topics/:id]()

type: `GET`

成功时返回：
```javascript
  {
    参考Topic对象的key/value
    comments: [{参照comment对象},...],
  }
```

----
# 对象查询

##User对象 

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


## Star对象

```javascript
  {
    id:star_id,
    name: "明星的名字",
    avatar: "明星的头像",
    is_followed: "是否被关注",
    concerts:{Concert对象},//当need_concerts不为false的时候
    shows:{Show对象},//当need_shows不为false的时候
    topics:{Topic对象},//当need_topics不为false的时候
  }
```

## Concert对象
```javascript
{
  id: concert_id,
  name: "Concert名称",
  description: "介绍",
  start_date: "众筹开始时间",
  end_date: "众筹结束时间"
  poster: "海报url",
  status: "voting(众筹中) or finished(众筹结束)"
  followers_count: "关注数",
  comments_count: "评论数",
  shows_count: "演唱会数目",
  voters_count: "投票人数",
  is_followed: "是否被关注",
  is_voted: "是否被投票",
  stars: {Star对象},//当need_stars不为false的时候
  shows: {Show对象}//当need_shows不为false的时候
}
```

## Show对象
```javascript
{
  id: show_id,
  name: "Show名称",
  min_price: "最小价格",
  max_price: "最高价格",
  concert_id: "concert_id",
  city_id: "city_id",
  stadium_id: "stadium_id",
  show_time: "开show时间",
  poster: "海报url",
  concert: {concert对象},
  city: {city对象}
  stadium: {stadium对象}
}
```

## City对象
```javascript
{
  id: city_id,
  pinyin: "城市名称的拼音",
  name: "城市名字",
  code: "城市代码",
}
```

## Stadium对象
```javascript
{
  id: stadium_id,
  name: "场馆名字",
  address: "场馆地址",
  longitude: "经度",
  latitude: "维度",
  city: {City对象}
}
```


## Topic对象
```javascript
{
  id: "id",
  content: "话题内容",
  city: {城市对象}.
  subject_type: "Star or Concert", //话题的主体
  subject_id: "star_id or concert_id", //话题的主体id
  creator:  {
    name: "名称",
    avatar: "头像url",
    is_admin: "true or false" //是否由运营人员创建
  }, //"话题创建者，可以是用户或者明星或者演唱会运营人员"
  like_count: "点赞的数目",
  comments_count: "comment的数目",
  created_at: "话题创建时间",
  is_top: "true or false", //是否置顶
  is_liked: "true or false"//是否点赞过
}
```

## Comment对象
```javascript
{
  id: comment_id,
  topic_id: Topic的id,
  parent_id: 如果是回复，parent_id代表被回复Comment的id,
  content: "评论",
  user: {:id, :nickname, :avatar},
}
```

## Order对象
```javascript
{
  out_id: 123,
  amount: 99.9,
  concert_name: "演唱会名字",
  concert_id: 123, //演唱会id
  stadium_id: 123, //场馆id
  stadium_name: "场馆名字",
  show_name: "演出名字",
  show_id: 123, //演出id
  city_name: "城市名字",
  city_id: 123, //城市id
  status: "pending" or "paid" or "success" or "refund"or "outdate", //分别表示“未支付”，“已支付”，“已出票”，“退款”，“过期”
  tickets: [{Ticket对象1},{Ticket对象2}...],
  created_at: "201504102140270000",
  updated_at: "201504102140270000",
  valid_time: "201504102140270000"
}
```

## Ticket对象
