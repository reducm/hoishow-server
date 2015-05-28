# API V1 不需登录

## 基础参数，错误返回码
1. 所有api请求时，url后需要带`.json`
2. api成功返回时参照各api描述，失败时统一返回:`{errors: "..."}`, 状态403

--------

## 物流查询接口
[/api/v1/express_detail]()

type `GET`

description: 查询顺丰物流详情

必要参数
```javascript
   { code: 432423 //快递单号 }
```

成功时返回
```javascript
   { express_url: 'xxxx' //物流查询的h5页面链接 }
```


--------

## 启动页广告
[/api/v1/startup]()

type: `GET`

description: 启动时的欢迎页面

成功时返回:
```javascript
  {
    id: 1 //启动页id,
    pic: 'xxxxx' //图片地址,
    valid_time: 1231231 //图片有效期时间戳
  }
```


--------

## Banner列表
[/api/v1/banners]()

type: `GET`

description: 推荐页面banner展示

成功时返回:
```javascript
  [banner对象列表] //参考Banner对象
```

--------

## 明星列表
[/api/v1/stars]()

type: `GET`

description: 推荐页面star列表

成功时返回：
```javascript
  [star对象列表] //参考Star对象
```

--------
## 搜索明星
[/api/v1/stars/search]()

type: `GET`

description: star搜索

必选参数
```javascript
  {
    q: "查询关键字"
  }
```

成功时返回：
```javascript
  [star对象列表] //参考Star对象
```

----

## 明星详情
[/api/v1/stars/:id]()

type: `GET`

description: star详情

可选参数
```javascript
  {
    mobile: "13512310293",
    api_token: "ASDKAJSDKASJDLAKSD"   //判断用户是否关注该明星
  }
```

成功时返回：
```javascript
  {star对象}
```

-------------

## 演唱会列表
[/api/v1/concerts/]()

type: `GET`

description: 演出页面众筹列表

可选参数
```javascript
  {
    page: "2" //页码
  }
```

成功时返回：
```javascript
  [concert对象列表] //参考Concert对象
```

----
## 演唱会详情
[/api/v1/concerts/:id]()

type: `GET`

description: concert详情

可选参数
```javascript
  {
    mobile: "13512310293",
    api_token: "ASDKAJSDKASJDLAKSD"  //判断用户是否关注或者投票
  }
```

成功时返回：
```javascript
  {concert对象}
```

-----------
## Concert城市投票排名
[/api/v1/concerts/:id/city_rank]()

type: `GET`

description: concert详情里面查看城市投票排名

成功时返回：
```javascript
  //按照投票数的由高到低排序
  [{
    City对象
  }]
```

-------
## 演出列表

[/api/v1/shows/]()

type: `GET`

descrption: 演出页面开show列表

可选参数
```javascript
  {
    page: "2" //页码
  }

成功时返回
```javascript
  {{show对象列表}}  // 参考Show对象
```


----
## 演出详情
[/api/v1/shows/:id]()

type: `GET`

descrption: show详情

成功时返回：
```javascript
  {show对象}
```

----

## 买票、选区接口

[/api/v1/shows/:id/preorder]()

type `GET`

descrption: 点击购票后选区

成功时返回
```javascript
{
  stadium: {stadium对象}
  show: {Show对象}
}
```

------------

## 话题列表

[/api/v1/topics/]()

type: `GET`

description: star/concert/show任一详情页面的互动列表

可选参数
```javascript
  {
    page: "2" //页码, 默认是1
    subject_type: 'Star/Concert/Show' //若不指定subject默认返回全部topic
    subject_id: star's id or concert's id //若不指定subject默认返回全部topic
  }
```

成功时返回
```javascript
  {[topic对象列表]}
```

----

## 话题详情
[/api/v1/topics/:id]()

type: `GET`

description: 互动详情以及评论列表

成功时返回：
```javascript
  {topic对象}
```

------------

## 城市列表(暂时不用)

[/api/v1/cities/]()

type: `GET`

可选参数
```javascript
  {
    page: "2" //页码
  }
```

成功时返回
```javascript
  {
    cities: [{参照city对象},...]
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
    id: 2,
    name:  //Star名称,
    avatar:  //明星的头像地址,
    poster:  //海报url,
    position: 8, //明星的排序
    status_cn: "开售中" or "投票中" or "无演出"
    description: "图文描述URL"
    is_followed: false //如果传用户信息，将会返回用户是否关注该明星，否则统一为false
    followers_count: 123, //粉丝数量
    concerts: [{Concert对象},...],//当need_concerts不为false的时候
    shows: [{Show对象},...],//当need_shows不为false的时候
    topics: [{Topic对象},...],//当need_topics不为false的时候
    video: {Video对象}, //明星没有主视频时返回null
  }
```

## Concert对象
```javascript
{
  id: concert_id,
  name: //Concert名称,
  description: //图文描述的url,
  start_date: //众筹开始时间,
  end_date:  //众筹结束时间,
  poster: //海报url,
  status: //voting(众筹中)/finished(众筹结束),
  followers_count:  //关注数,
  shows_count:  //演唱会数目,
  voters_count: //投票人数,
  is_followed: //是否被关注,
  is_voted: //是否被投票,
  is_top: "true or false", //是否置顶
  voted_city: {City对象}, //用户登录时对本concert投过票的城市
  stars: [Star对象列表], //当need_stars不为false的时候
  topics: [Topic对象列表], //当need_topics不为false的时候
  shows: [Show对象列表]  //当need_shows不为false的时候
}
```

## Show对象
```javascript
{
  id:  //show_id,
  name:  //Show名称,
  concert_id:  //concert_id,
  concert_name:  //concert名称,
  city_id:  //city_id,
  city_name: //city名称,
  stadium_id:  //stadium_id,
  stadium_name: //stadium名称,
  show_time:  //开show时间,
  poster:  //海报url,
  description:  //图文介绍的url,
  is_followed:  //是否被关注,
  is_voted:  //是否被投票,
  is_top: "true or false", //是否置顶
  voters_count: //投票数,
  status:  // voted_users(投票用户购买)/all_users(所有用户购买)
  ticket_type:  // 分成实体票与电子票两种
  concert: {concert对象},  //当need_concert不为false的时候
  city: {city对象},  //当need_city不为false的时候
  stadium: {stadium对象},  //当need_stadium不为false的时候
  topics: [topic对象列表]  //当need_topics不为false的时候
}
```

## City对象
```javascript
{
  id: city_id,
  pinyin: "城市名称的拼音",
  name: "城市名字",
  code: "城市代码",
  vote_count: 0   //请求城市排名的时候才有
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
  city: {City对象}, //当need_city不为false的时候
  pic: "场馆的图片"
  area: [area对象列表] //当need_areas不为false的时候
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
    id: ID
    name: "名称",
    avatar: "头像url",
    is_admin: "true or false" //是否由运营人员创建
  }, //"话题创建者，可以是用户或者明星或者演唱会运营人员"
  like_count: "点赞的数目",
  comments_count: "comment的数目",
  created_at: "话题创建时间",
  is_top: "true or false", //是否置顶
  is_liked: "true or false"//是否点赞过
  comments: [comment对象列表]
}
```

## Comment对象
```javascript
{
  id: comment_id,
  topic_id: "话题的id",
  parent_id: "如果有回复的话，此为被回复comment的id",
  parent_comment: 参照comment对象,
  content: "评论",
  creator:  {
    id: ID
    name: "名称",
    avatar: "头像url",
    is_admin: "true or false" //是否由运营人员创建
  }, //"话题创建者，可以是用户或者明星或者演唱会运营人员"
}
```

## Order对象
```javascript
{
  out_id: 123,
  amount: 99.9,
  show: Show对象,  //当need_show不为false时
  concert: Concert对象, //当need_concert不为false时
  stadium: Stadium对象, //当need_stadium不为false时
  city: City对象,  //当need_city不为false时
  tickets: [tickets对象列表], //当need_tickets不为false时
  concert_name: "演唱会名字",
  concert_id: 123, //演唱会id
  stadium_id: 123, //场馆id
  stadium_name: "场馆名字",
  show_name: "演出名字",
  show_id: 123, //演出id
  city_name: "城市名字",
  city_id: 123, //城市id
  express_id: "97698906987", //快递单号
  user_name: "tom", //收货人姓名
  user_mobile: "11012013099", //收货人电话
  user_address: "广东省广州市越秀区不是鸠路", //收货人完整地址
  status: "pending" or "paid" or "success" or "refund"or "outdate", //分别表示“未支付”，“已支付”，“已出票”，“退款”，“过期”
  poster: //海报url
  tickets_count: //票数
  show_time: '201504102140270000' //show的演出时间
  created_at: "201504102140270000",
  updated_at: "201504102140270000",
  valid_time: "201504102140270000"  //15分钟过期
}
```

## Area对象

```javascript
{
  name: "A区",
  seats_count: 11, //座位数
  stadium_id: 22, //场馆id
  created_at: "201504102140270000",
  updated_at: "201504102140270000",
  price: 1,  //票价
  seats_left: 10,  //剩余票数
  is_sold_out: false   //是否卖完
}
```

## Ticket对象

```javascript
{
  area: {Area对象},
  area_id: 11, //区域id
  show_id: 22, //演出id
  price: 99.00, //价格
  code: 'xsdadasdxxdasd'  //票码
  status: "pending" or "success" or "used", //"pending": 未支付，没有code, "success": 可用, "used": 已用
  created_at: "201504102140270000",
  updated_at: "201504102140270000"
}
```

## Banner对象

```javascript
{
  id: 1,
  poster: "poster_url",
  subject_type:  //Star or Show or Concert or Article,
  subject_id:  //当subject_type是Article的时候为null
  subject: {Star or Show or Concert对象},
  description:  //当subject_type是Article的时候才有, description是图文链接的url
}
```

## Video对象

```javascript
{
  source: "视频url",
  snapshot: "截图url",
}
```

## Message对象

```javascript
{
  title: 'xxx',
  content: "截图url",
  redirect_url: 'xxxxx' //点击message后跳转的url
  creator:  {
    id: ID
    name: "名称",
    avatar: "头像url",
    is_admin: "true or false" //是否由运营人员创建
  }, // 消息创建者，可以是用户或者明星或者演唱会运营人员
}
```
