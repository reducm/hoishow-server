class ViagogoMailer < ApplicationMailer
  default :from => "dc-notify@bestapp.us"

  def notify_user_ticket_pic(order)
    @order = order
    #attachments['门票.pdf'] = File.read(order.ticket_pic.current_path)  
    #attachments['门票.pdf'] = File.read(order.ticket_pic_url)  
    mail(to: "tom@bestapp.us", subject: "演出门票test")
  end

end
