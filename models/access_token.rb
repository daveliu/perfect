require 'net/http'

class AccessToken < ActiveRecord::Base
  def self.get!
    appid = "wx3e91af0fe94bafb5"
    secret = "35b57e9d071d1fec96983f8559bcbf94"
    
    url = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{appid}&secret=#{secret}"
    uri = URI(url)
    response = Net::HTTP.get_response(uri)
    AccessToken.create(:content => JSON.parse(response.body)["access_token"])
  end
  
  def self.only
    if AccessToken.last.blank? ||  Time.now - AccessToken.last.created_at > 6500.seconds
      AccessToken.get!      
    end
    AccessToken.last.content            
  end

end
