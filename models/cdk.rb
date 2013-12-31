class Cdk < ActiveRecord::Base
  validates_uniqueness_of :content
  
  def self.send_to(uid)
    cdk = Cdk.where(:send_at => nil).first
    cdk.uid = uid
    cdk.send_at  = Time.now
    cdk.save
    cdk    
  end

end
