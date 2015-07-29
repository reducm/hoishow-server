require 'spec_helper'

describe Show do
  context "validation" do
    # it "min_price should smaller than max_price" do
    #   show = build(:show, min_price: 10.0, max_price: 5.0)
    #   expect(show.valid?).to be false
    #   expect(show).to have(1).error_on(:min_price)
    # end

    it "concert should be presence" do
      show = build(:show, concert: nil)
      expect(show.valid?).to be false
      expect(show).to have(1).error_on(:concert)
    end

    it "stadium should be presence" do
      show = build(:show, stadium: nil)
      expect(show.valid?).to be false
      expect(show).to have(1).error_on(:stadium)
    end

    it "response to stars" do
      show = create(:show)
      expect(show.respond_to?(:stars)).to be true
      expect(show.stars).to eq show.concert.stars
    end
  end

  context "test paginate" do
    before('each') do
      200.times do
        create :show
      end
    end
    it "per 20" do
      expect( Show.page(2).size ).to eq 10
    end

    it "page2's model should be correct" do
      shows = Show.all
      expect(shows.index Show.page(2).first).to be 10
    end
  end

  context "#setas_count" do
    before('each') do
      @user = create :user
      @stadium = create :stadium
      10.times{create :area, stadium: @stadium}
      @show = create :show, stadium: @stadium
      Area.all.each_with_index do |area, i|
        relation = create :show_area_relation, area: area, show: @show
        2.times do
          order = @user.orders.init_from_show(@show)
          order.save
          create :ticket, order_id: order.id, show_id: @show.id, area_id: area.id
          #order.set_tickets_and_price([relation, relation])
        end
        relation.decrement(:left_seats, 4).save!
      end
    end

    it "each area's seats_left should be right" do
      Area.all.each do |area|
        expect( @show.area_seats_left(area) ).to eq ( @show.show_area_relations.where(area: area).first.seats_count - 4 )
      end
    end
  end
end
