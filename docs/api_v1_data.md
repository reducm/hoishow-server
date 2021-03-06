# API V1 不需登录

## 基础参数，错误返回码
1. 所有api请求时，url后需要带`.json`
2. api成功返回时参照各api描述，失败时统一返回:`{errors: "..."}`, 状态403


--------

## 反馈
[/api/v1/feedbacks]()

type `POST`

description: 用户提交意见反馈

必选参数

```javascript
   {
     content: 'hello' //反馈内容
     mobile: '13888888888' //联系方式
   }
```

成功时返回: `{msg: "ok"}` 返回状态码200

--------

## 点击选座
[/api/v1/shows/[:id]/click_seat]()

type `GET`

description: 用户在h5选座页面点击某个座位时发起请求

传递参数

```javascript
  {
    id: 1 //演出id
    show_name: 'abc' //演出名字
    area_id: 1 //区域id
    area_name: 'A区' //区域名字
    seat_id: 1 //座位id
    seat_name: '10排8座' //座位名
    price: 100  //票价
    status: 'avaliable'/'checked' //座位状态
    remark: 'xxx'  //备注
  }
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
  {concert对象},
  cities: [{city1}, {city2}...]
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

## 选座接口

[/api/v1/shows/:id/seats_info]()

type `GET`

description: 点击区域后选座

必需参数
```javascript
   {
     area_id: 1 //选择的区域id
   }
```

成功时返回
```javascript
   {area对象}
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
  description_time: //用这个时间替换start_date跟end_date,
  start_date: //众筹开始时间,
  end_date:  //众筹结束时间,
  poster: //海报url,
  status: //voting(众筹中)/finished(众筹结束),
  followers_count:  //关注数,
  shows_count:  //演唱会数目,
  voters_count: //投票人数(包含底数),
  sharing_page: 'xxxx' //分享页url,
  is_followed: //是否被关注,
  is_voted: //是否被投票,
  is_top: "true or false", //是否置顶
  is_show: "showing or hidden or auto_hide", //showing: 显示，hidden：不显示，auto_hide：直接开show不投票
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
  ticket_pic:  //门票图片url,
  description:  //图文介绍的url,
  description_time:  //当show的status为going_to_open时显示这个时间替代show_time,
  is_followed:  //是否被关注,
  is_voted:  //是否被投票,
  is_top: "true or false" //是否置顶,
  sharing_page: 'xxxx' //分享页url,
  voters_count: //投票数(包含底数),
  status:  // selling(售票中)/sell_stop(售票结束)/going_to_open(即将开放),
  ticket_type:  // e_ticket(电子票)/r_ticket(实体票),
  stadium_map: 'xxx' //场馆图
  seat_type: // selectable(可以选座)/selected(只能选区)
  mode:  // voted_users(投票用户购买)/all_users(所有用户购买),
  concert: {concert对象},  //当need_concert不为false的时候
  city: {city对象},  //当need_city不为false的时候,
  areas: [area对象列表], //当need_areas不为false的时候,
  stadium: {stadium对象},  //当need_stadium不为false的时候
  topics: [topic对象列表],  //当need_topics不为false的时候
  stars: [star对象列表]  //当need_stars不为false的时候
}
```

## City对象
```javascript
{
  id: city_id,
  pinyin: "城市名称的拼音",
  name: "城市名字",
  code: "城市代码",
  is_show: true //城市是否开show
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
    is_star: "true or false" //是否是明星
  }, //"话题创建者，可以是用户或者明星或者演唱会运营人员"
  like_count: "点赞的数目",
  comments_count: "comment的数目",
  created_at: "话题创建时间",
  city_name: "用户所投城市的名字",
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
  created_at: "回复创建时间",
  content: "评论",
  creator:  {
    id: ID
    name: "名称",
    avatar: "头像url",
    is_admin: "true or false" //是否由运营人员创建
    is_star: "true or false" //是否是明星
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
  express_code: "97698906987", //快递单号
  express_id: 123, //用户最新的地址id
  user_name: "tom", //收货人姓名
  user_mobile: "11012013099", //收货人电话
  user_address: "收货人地址(除了省,市,区之外的地址)",
  province_address: "收货地址的省",
  city_address: "收货地址的市",
  district_address: "收货地址的区",
  order_address: "订单完整地址"
  status: "pending" or "paid" or "success" or "refund"or "outdate", //分别表示“未支付”，“已支付”，“已出票”，“退款”，“过期”
  poster: //海报url
  tickets_count: //票数
  ticket_type:  // e_ticket(电子票)/r_ticket(实体票),
  qr_url: 'xxx' //二维码地址
  show_time: '201504102140270000' //show的演出时间
  created_at: "201504102140270000",
  updated_at: "201504102140270000",
  valid_time: "201504102140270000"  //15分钟过期
}
```

## Area对象

```javascript
{
  id: area对象的id,
  name: "A区",
  seats_count: 11, //座位数
  stadium_id: 22, //场馆id
  created_at: "201504102140270000",
  updated_at: "201504102140270000",
  price: 1,  //票价
  seats_left: 10,  //剩余票数
  is_sold_out: false   //是否卖完
  seats_map: 'xxxs' //选座图url
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
  seat_name: '1排1座' //座位号
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
  subject_type:  //Star or Show or Concert or Topic,
  subject_id: //subject的id
  created_at: //消息创建的时间
  creator:  {
    id: ID
    name: "名称",
    avatar: "头像url",
    is_admin: "true or false" //是否由运营人员创建
  }, // 消息创建者，可以是用户或者明星或者演唱会运营人员
  is_new: true or false //是否为新消息
}
```
