require 'spec_helper'

describe YongleService::Fetcher do
  before(:each) do
    @area = create(:yongle_area, event_id: event.id, seats_count: 2, left_seats: 2)
    @relation = create(:show_area_relation, area_id: @area.id, show_id: show.id, seats_count: 2, left_seats: 2) 
    2.times { create(:seat, show_id: show.id, area_id: @area.id, order_id: nil) }
  end

  let(:show) { create(:show) }
  let(:event) { create(:event, show_id: show.id) }

  context "#fetch_productprice_info" do
    it "should set inventory 0 if not_enough_inventory" do
      result_data = {
        "result"=>"1000",
        "message"=>"成功",
        "data"=>{
          "tickSetInfo"=>{
            "productId"=>"68962692",
            "productPlayid"=>"68962736",
            "price"=>"80.00",
            "priceInfo"=>"80",
            "priceType"=>"1",
            "priceStarus"=>"1",
            "priceNum"=>"-2" # negative inventory number 
          }
        }
      }
      allow(YongleService::Service).to receive(:find_productprice_info).and_return(result_data)
      YongleService::Fetcher.fetch_productprice_info(@area.source_id)
      expect(@relation.reload.seats_count).to eq 0
      expect(@relation.left_seats).to eq 0
      expect(@relation.price).to eq result_data["data"]["tickSetInfo"]["price"].to_i
      expect(@area.reload.seats_count).to eq 0
      expect(@area.left_seats).to eq 0
      expect(@area.name).to eq result_data["data"]["tickSetInfo"]["priceInfo"]
      expect(Ticket.count).to eq 0
    end

    it "should set inventory 0 if not_for_sell" do
      result_data = {
        "result"=>"1000",
        "message"=>"成功",
        "data"=>{
          "tickSetInfo"=>{
            "productId"=>"68962692",
            "productPlayid"=>"68962736",
            "price"=>"80.00",
            "priceInfo"=>"80",
            "priceType"=>"1",
            "priceStarus"=>["2", "3"].sample, # not_for_sell 
            "priceNum"=>"2"
          }
        }
      }
      allow(YongleService::Service).to receive(:find_productprice_info).and_return(result_data)
      YongleService::Fetcher.fetch_productprice_info(@area.source_id)
      expect(@relation.reload.seats_count).to eq 0
      expect(@relation.left_seats).to eq 0
      expect(@area.reload.seats_count).to eq 0
      expect(@area.left_seats).to eq 0
      expect(Ticket.count).to eq 0
    end

    it "should set inventory 30 if 'Yongle infinite inventory'" do
      result_data = {
        "result"=>"1000",
        "message"=>"成功",
        "data"=>{
          "tickSetInfo"=>{
            "productId"=>"68962692",
            "productPlayid"=>"68962736",
            "price"=>"80.00",
            "priceInfo"=>"80",
            "priceType"=>"1",
            "priceStarus"=>["1", "4"].sample, # for sell 
            "priceNum"=>"-1" # Yongle infinite inventory
          }
        }
      }
      allow(YongleService::Service).to receive(:find_productprice_info).and_return(result_data)
      YongleService::Fetcher.fetch_productprice_info(@area.source_id)
      expect(@relation.reload.seats_count).to eq 30
      expect(@relation.left_seats).to eq 30
      expect(@area.reload.seats_count).to eq 30
      expect(@area.left_seats).to eq 30
      expect(@area.is_infinite).to eq true
      expect(Ticket.count).to eq 30
    end
    
    it "should set inventory by fetched number if enough_inventory and for_sell" do
      result_data = {
        "result"=>"1000",
        "message"=>"成功",
        "data"=>{
          "tickSetInfo"=>{
            "productId"=>"68962692",
            "productPlayid"=>"68962736",
            "price"=>"80.00",
            "priceInfo"=>"80",
            "priceType"=>"1",
            "priceStarus"=>["1", "4"].sample, # for sell 
            "priceNum"=>"66" # positive inventory number
          }
        }
      }
      allow(YongleService::Service).to receive(:find_productprice_info).and_return(result_data)
      YongleService::Fetcher.fetch_productprice_info(@area.source_id)
      expect(@relation.reload.seats_count).to eq result_data["data"]["tickSetInfo"]["priceNum"].to_i
      expect(@relation.left_seats).to eq result_data["data"]["tickSetInfo"]["priceNum"].to_i
      expect(@area.reload.seats_count).to eq result_data["data"]["tickSetInfo"]["priceNum"].to_i
      expect(@area.left_seats).to eq result_data["data"]["tickSetInfo"]["priceNum"].to_i
      expect(Ticket.count).to eq result_data["data"]["tickSetInfo"]["priceNum"].to_i
    end

    it "should set inventory 0 if result '1003'" do
      result_data = {
        "result"=>"1003",
        "message"=>"联盟查询票价接口(findProductpriceInfo)_没有此票价/联盟id不正确： unionId: 53658423 票价id: 2",
        "data"=>nil
      }
      allow(YongleService::Service).to receive(:find_productprice_info).and_return(result_data)
      YongleService::Fetcher.fetch_productprice_info(@area.source_id)
      expect(@relation.reload.seats_count).to eq 0
      expect(@relation.left_seats).to eq 0
      expect(@area.reload.seats_count).to eq 0
      expect(@area.left_seats).to eq 0
      expect(Ticket.count).to eq 0
    end
  end
end
