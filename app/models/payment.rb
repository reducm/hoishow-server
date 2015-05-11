class Payment < ActiveRecord::Base
  belongs_to :order

  def generate_batch_no
    t = Time.now
    batch_no = t.strftime('%Y%m%d%H%M%S') + "O" + self.id.to_s.rjust(6, '0')
  end
end
