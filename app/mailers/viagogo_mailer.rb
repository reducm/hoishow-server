class ViagogoMailer < ApplicationMailer
  default :from => "dc-notify@bestapp.us"

  def notify_user_ticket_pic(order)
    @order = order
    if user_email = @order.user.email
      attachments['门票.pdf'] = File.read(order.ticket_pic_url)  
      mail(to: user_email, subject: "演出门票test")
    end
    #attachments['门票.pdf'] = File.read(order.ticket_pic.current_path)  
    #mail(to: "tom@bestapp.us", subject: "演出门票test")
    #mail(to: "ffu9395@gmail.com", subject: "演出门票test")
  end

end
