module PagesHelper
  def get_ticket_price(show)
    if show.selectable?
      show.seats.map{|relation| relation.price.to_i}.uniq.join("/")
    elsif show.selected?
      show.show_area_relations.map{|relation| relation.price.to_i}.uniq.join("/")
    end
  end
end
