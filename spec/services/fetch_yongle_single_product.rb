require 'spec_helper'

describe "YongleService::Fetcher" do
  context "#fetch_product" do
    it "should fetch CitySource, Stadium, Show, Event, Area, Relation when return code is '1000'" do
      # TODO Put json sample in file and read from it, here should only contain test code.
      # YongleService::Service.get_product return sample
      product = {
        "result" => "1000",
        "message" => "成功",
        "data" => {
          "products" => {
            "product" => {
              "productId" => "103090508",
              "playName" => "音乐童话剧《心花怒放》",
              "nameSynonym" => "心花怒放北京儿童剧、音乐童话剧心花怒放",
              "onlineseat" => "1",
              "status" => "0",
              "shelfStatus" => "1",
              "dispatchWayList" => {
                "dzp_dispatchWay" => "0",
                "dzp_type" => "-",
                "dzp_message" => "-",
                "smzq_dispatchWay" => "1",
                "smzq_address" => "北京市王家园胡同16号中国儿童福利大厦西门1层（富华大厦向东50米路南）",
                "smzq_time" => "周一至周日 9:00—18:00",
                "smzq_message" => "取票时请携带和所填姓名一致的身份证！",
                "kdps_dispatchWay" => "1",
                "kdps_message" => "我们会尽快发货，发货后本市一般1-3天内到达，外省市3-7天内到达"
              },
              "fconfigId" => "1",
              "playCityId" => "1",
              "playCity" => "北京市",
              "playAddressId" => "143634",
              "playAddress" => "北青盈之宝剧场",
              "playTypeAId" => "142458",
              "playTypeBId" => "142539",
              "playTypeA" => "儿童亲子",
              "playTypeB" => "儿童剧",
              "productPicture" => "http://static.228.cn/upload/2016/04/15/AfterTreatment/1460703498276_w4m7-0.jpg",
              "productPictureSmall" => "http://static.228.cn/upload/2016/04/15/AfterTreatment/1460703498276_w4m7-1.jpg",
              "seatPicture" => "http://static.228.cn/upload/2016/04/19/1461055529170_j9p5_m1.jpg",
              "productStartTime" => "2016-06-04",
              "productEndTime" => "2016-06-05",
              "unionId" => "53658423",
              "Sharedescribe" => "音乐童话剧《心花怒放》演出将于2016-06-04在北青盈之宝剧场开场演出,永乐票务将为您提供音乐童话剧《心花怒放》儿童剧北青盈之宝剧场演出门票在线预订服务。",
              "ProductProfile" => "<p style=\"text-indent:2em;\"><strong>剧情介绍</strong><br /></p><p style=\"text-indent:2em;\">一位可爱的“空中邮差”</p><p style=\"text-indent:2em;\">四封没有地址的信<span style=\"text-indent:24px;\">。</span></p><p style=\"text-indent:2em;\">三段奇妙的经历<span style=\"text-indent:24px;\">。</span></p><p style=\"text-indent:2em;\">串联起天上人间共通的生命真谛<span style=\"text-indent:24px;\">。</span></p><p><br /></p><p style=\"text-indent:2em;\">空中邮差小飞，第一次降落凡间送信。</p><p style=\"text-indent:2em;\">四封没有地址、没有收件人、连邮票都没有的空白信封，</p><p style=\"text-indent:2em;\">唯一的指示：“向东走”</p><p style=\"text-indent:2em;\">小飞该如何将信送到正确的人手中？</p><p><br /></p><p style=\"text-indent:2em;\">一个幸福的家庭，因为母亲的去世，变成到处招摇撞骗的流浪团体。 </p><p style=\"text-indent:2em;\">一心寻找海巿蜃楼的冒险家们，因飞机故障被困在沙漠中。 </p><p style=\"text-indent:2em;\">两个一直捧着月亮的老人，不愿让月亮回天上去。</p><p><br /></p><p style=\"text-indent:2em;\">2016北京音乐童话剧《心花怒放》敬请期待！<br /></p>a)演出详情仅供参考，具体信息以现场为准；</br>b)儿童需持票入场；</br>c)演出票品具有唯一性、时效性等特殊属性，如非活动变更、活动取消、票品错误的原因外，不提供退换票品服务，购票时请务必仔细核对并审慎下单。",
              "venueIntroduction" => "位于北京市朝阳区利泽东二路二号盈之宝店三层。由北京青年报下属的北青文化艺术、北京儿艺携手北京盈之宝汽车销售服务公司共同倾力打造的京城第一家时尚高端剧场。剧场座落于代表着北京新一代时尚与文化的望京社区。剧场推出全新“赏戏”理念，提出独创的北青盈之宝剧场“赏戏”流程，为培养高端艺术演出和展示市场的观众做出实质性努力。",
              "venueMap" => "地铁13号线望京西出，转446、547望京北路东口下车，向北直行500米。乘623、420路到望京科技创业园总站，下车即到。望京东北方五环内，宝马4S店，周边有双鹤药业、北京市老年人活动中心。",
              "venueStall" => "朝阳区利泽东二路二号3层（望京科技园区东北角）",
              "ticketTimeList" => {
                "ticketTimeInfo" => [
                  {
                    "ticketTime" => "2016-06-04 10:30",
                    "tickSetInfoList" => {
                      "tickSetInfo" => [
                        {
                          "productPlayid" => "103090605",
                          "price" => "80.00",
                          "priceInfo" => "80",
                          "priceStarus" => "1",
                          "priceType" => "1",
                          "priceNum" => "-1"
                        },
                        {
                          "productPlayid" => "103090606",
                          "price" => "100.00",
                          "priceInfo" => "100",
                          "priceStarus" => "1",
                          "priceType" => "1",
                          "priceNum" => "-1"
                        },
                        {
                          "productPlayid" => "103090607",
                          "price" => "150.00",
                          "priceInfo" => "150",
                          "priceStarus" => "1",
                          "priceType" => "1",
                          "priceNum" => "-1"
                        }
                      ]
                    }
                  },
                  {
                    "ticketTime" => "2016-06-04 15:00",
                    "tickSetInfoList" => {
                      "tickSetInfo" => [
                        {
                          "productPlayid" => "103175823",
                          "price" => "80.00",
                          "priceInfo" => "80",
                          "priceStarus" => "1",
                          "priceType" => "1",
                          "priceNum" => "-1"
                        },
                        {
                          "productPlayid" => "103175824",
                          "price" => "100.00",
                          "priceInfo" => "100",
                          "priceStarus" => "1",
                          "priceType" => "1",
                          "priceNum" => "-1"
                        },
                        {
                          "productPlayid" => "103175825",
                          "price" => "150.00",
                          "priceInfo" => "150",
                          "priceStarus" => "1",
                          "priceType" => "1",
                          "priceNum" => "-1"
                        }
                      ]
                    }
                  },
                  {
                    "ticketTime" => "2016-06-05 10:30",
                    "tickSetInfoList" => {
                      "tickSetInfo" => [
                        {
                          "productPlayid" => "103090608",
                          "price" => "80.00",
                          "priceInfo" => "80",
                          "priceStarus" => "1",
                          "priceType" => "1",
                          "priceNum" => "-1"
                        },
                        {
                          "productPlayid" => "103090609",
                          "price" => "100.00",
                          "priceInfo" => "100",
                          "priceStarus" => "1",
                          "priceType" => "1",
                          "priceNum" => "-1"
                        },
                        {
                          "productPlayid" => "103090610",
                          "price" => "150.00",
                          "priceInfo" => "150",
                          "priceStarus" => "1",
                          "priceType" => "1",
                          "priceNum" => "-1"
                        }
                      ]
                    }
                  },
                  {
                    "ticketTime" => "2016-06-05 15:00",
                    "tickSetInfoList" => {
                      "tickSetInfo" => [
                        {
                          "productPlayid" => "103175826",
                          "price" => "80.00",
                          "priceInfo" => "80",
                          "priceStarus" => "1",
                          "priceType" => "1",
                          "priceNum" => "-1"
                        },
                        {
                          "productPlayid" => "103175827",
                          "price" => "100.00",
                          "priceInfo" => "100",
                          "priceStarus" => "1",
                          "priceType" => "1",
                          "priceNum" => "-1"
                        },
                        {
                          "productPlayid" => "103175828",
                          "price" => "150.00",
                          "priceInfo" => "150",
                          "priceStarus" => "1",
                          "priceType" => "1",
                          "priceNum" => "-1"
                        }
                      ]
                    }
                  }
                ]
              }
            }
          }
        }
      }
      # YongleService::Service.venue_info return sample
      venue_info = {
        "result" => "1000",
        "message" => "成功",
        "data" => {
          "Response" => {
            "getVenueInfoRsp" => {
              "venue" => {
                "venueId" => "143634",
                "venueName" => "北青盈之宝剧场",
                "cityId" => "1",
                "cityName" => "北京",
                "introduction" => "位于北京市朝阳区利泽东二路二号盈之宝店三层。由北京青年报下属的北青文化艺术、北京儿艺携手北京盈之宝汽车销售服务公司共同倾力打造的京城第一家时尚高端剧场。剧场座落于代表着北京新一代时尚与文化的望京社区。剧场推出全新“赏戏”理念，提出独创的北青盈之宝剧场“赏戏”流程，为培养高端艺术演出和展示市场的观众做出实质性努力。",
                "bus" => "地铁13号线望京西出，转446、547望京北路东口下车，向北直行500米。乘623、420路到望京科技创业园总站，下车即到。望京东北方五环内，宝马4S店，周边有双鹤药业、北京市老年人活动中心。",
                "address" => "朝阳区利泽东二路二号3层（望京科技园区东北角）",
                "seatmapkeys" => "北青盈之宝剧场",
                "longitude" => "116.490206",
                "latitude" => "40.018114",
                "imgurlList" => {
                  "imgurl" => {
                    "url" => "http://static.228.cn//upload/2012/01/10/AfterTreatment/1201101503192207-0.jpg"
                  }
                }
              }
            }
          }
        }
      }

      allow(YongleService::Service).to receive(:get_product).and_return(product)
      product = product["data"]["products"]["product"]
      allow(YongleService::Service).to receive(:get_venue_info).and_return(venue_info)
      venue = venue_info["data"]["Response"]["getVenueInfoRsp"]["venue"]

      city_source = create(:city_source, yl_fconfig_id: product["fconfigId"].to_i)
      stadium = create(:stadium, source_id: product["playAddressId"].to_i, source: Stadium.sources["yongle"], city_id: city_source.city_id)
      concert = create(:concert)  
      show = create(:show, source_id: product["productId"].to_i, source: Show.sources["yongle"], concert_id: concert.id, stadium_id: stadium.id)

      YongleService::Fetcher.fetch_product('103090508')
      # CitySource 
      expect(city_source.reload.source_id).to eq product["playCityId"].to_i
      # Stadium
      expect(stadium.reload.name).to eq venue["venueName"]
      expect(stadium.address).to eq venue["address"]
      expect(stadium.longitude).to eq venue["longitude"].to_f - 0.0065
      expect(stadium.latitude).to eq venue["latitude"].to_f - 0.006
      # Show
      expect(show.reload.concert_id).to eq concert.id
      expect(show.city_id).to eq city_source.city_id
      expect(show.yl_play_city_id).to eq product["playCityId"].to_i
      expect(show.yl_fconfig_id).to eq product["fconfigId"].to_i
      expect(show.yl_play_address_id).to eq product["playAddressId"].to_i
      expect(show.yl_play_type_a_id).to eq product["playTypeAId"].to_i
      expect(show.yl_play_type_b_id).to eq product["playTypeBId"].to_i
      expect(show.name).to eq product["playName"]
      expect(show.description).to eq product["ProductProfile"]
      expect(show.status).to eq "selling"
      expect(show.is_presell).to eq product["status"].to_i == 1
      expect(show.ticket_type).to eq product["dispatchWayList"]["dzp_dispatchWay"].to_i == 1 ? "e_ticket" : "r_ticket"
      expect(show.yl_dzp_type).to eq product["dispatchWayList"]["dzp_dispatchWay"].to_i == 1 ? product["dispatchWayList"]["dzp_type"] : nil
      expect(show.seat_type).to eq "selected"
      # Event
      expect(Event.count).to eq product["ticketTimeList"]["ticketTimeInfo"].count
      event = Event.first
      expect(event.show_time).to eq DateTime.strptime(product["ticketTimeList"]["ticketTimeInfo"][0]["ticketTime"], '%Y-%m-%d %H:%M') - 8.hours
      # Area
      expect(event.areas.count).to eq product["ticketTimeList"]["ticketTimeInfo"][0]["tickSetInfoList"]["tickSetInfo"].count
      area = Area.first
      expect(area.source_id).to eq product["ticketTimeList"]["ticketTimeInfo"][0]["tickSetInfoList"]["tickSetInfo"][0]["productPlayid"].to_i
      expect(area.source).to eq "yongle"
      expect(area.name).to eq product["ticketTimeList"]["ticketTimeInfo"][0]["tickSetInfoList"]["tickSetInfo"][0]["priceInfo"]
      expect(area.stadium_id).to eq show.stadium.id
      # For detail inventory test, check spec/services/fetch_yongle_realtime.spec.rb
      # Relation
      relation = ShowAreaRelation.first
      expect(show.show_area_relations.count).to eq event.areas.count * Event.count
      # Ticket
      expect(area.tickets.count).to eq relation.left_seats
    end   
    # TODO Test case which return code is '1003'.
    # TODO Test case which return code is neither '1000' nor '1003'.
  end
end
