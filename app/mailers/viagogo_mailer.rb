class ViagogoMailer < ApplicationMailer
  default :from => %q("单车娱乐"<dc-notify@bestapp.us>)

  def notify_user_ticket_pic(order)
    @order = order
    if user_email = @order.user.email
      ticket_url = order.ticket_pic_url
      hz = ticket_url.split(".").last
      attachments["ticket.#{hz}"] = open(ticket_url){|f| f.read}
      #attachments["ticket.#{hz}"] = File.read(order.ticket_pic.current_path)  
      mail(to: user_email, subject: "出票成功")
    end
    #mail(to: "tom@bestapp.us", subject: "演出门票test")
    #mail(to: "ffu9395@gmail.com", subject: "演出门票test")
  end

end
