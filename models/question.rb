require 'carrierwave/orm/activerecord'
require 'net/http'
class Question < ActiveRecord::Base
  validates_presence_of :options
  validates_presence_of :answer
  
  mount_uploader :image, WeixinUploader
  mount_uploader :music, MusicUploader    
  
  after_save :upload_to_weixin
    
  def message_type
    self.image? ?  "image" : "voice"
  end
  
  def self.ask_uid(uid)
    user  = User.where(:uid => uid).first    
    m = Question.where(["id NOT IN (?)", user.right_question_array]).first
    
    m.ask_title(uid)
    m.ask_body(uid)
    m.ask_option(uid)  
    
    user.last_question_id = m.id
    user.save      
  end
  
  def ask_title(uid, text = "")
    user  = User.wehre(:uid => uid).first
    title = if self.image?
      "#{title} 第#{user.right_answers_counter + 1}题：请根据下面图片猜出相关内容。"
    else
      "#{title} 第#{user.right_answers_counter + 1}题：请听以下音乐片段猜测歌曲名称。"      
    end        

    access_token = AccessToken.only

    url = "https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{access_token}"
    json =     {
      "touser" => uid,
      "msgtype" => 'text',
      "text" =>
      {
        "content" => title
      }
    }.to_json       
    system(%Q(curl -X POST -H "Content-Type: application/json" -d '#{json}' #{url}) )
  end
  
  def ask_body(uid)
    access_token = AccessToken.only

    url = "https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{access_token}"
    json =     {
      "touser" => uid,
      "msgtype" => self.message_type,
      self.message_type =>
      {
        "media_id" => self.uid
      }
    }.to_json 

    system(%Q(curl -X POST -H "Content-Type: application/json" -d '#{json}' #{url}) )
  end
  
  def ask_option(uid)
    access_token = AccessToken.only

    url = "https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{access_token}"
    json =     {
      "touser" => uid,
      "msgtype" => 'text',
      self.message_type =>
      {
        "media_id" => self.options
      }
    }.to_json       
    system(%Q(curl -X POST -H "Content-Type: application/json" -d '#{json}' #{url}) )
  end
  
  private
  
  # 图片（image）: 128K，支持JPG格式
  # 语音（voice）：256K，播放长度不超过60s，支持AMR\MP3格式
  # 视频（video）：1MB，支持MP4格式
  # 缩略图（thumb）：64KB，支持JPG格式
  # 媒体文件在后台保存时间为3天，即3天后media_id失效。
  # 
  # 
  
  def upload_to_weixin
    
    access_token = AccessToken.only
        
    response = if self.image?
      asset_url = "#{Padrino.root}/public" + self.image.url(:thumb)
      type = "image"      
      
      begin
       RestClient.post("http://file.api.weixin.qq.com/cgi-bin/media/upload?access_token=#{access_token}&type=#{type}", 
                      :media => File.new(asset_url, 'rb'))
      rescue Exception => e
        logger.info "-------------------#{e}"                        
      end  
          
    elsif self.music?
      asset_url = "#{Padrino.root}/public/" + self.music.url
      type = "voice"
      
      RestClient.post("http://file.api.weixin.qq.com/cgi-bin/media/upload?access_token=#{access_token}&type=#{type}", 
                      :media => File.new(asset_url, 'rb'))
    end
    
    if response.present?
      puts "-------------------#{response.inspect}"
      # self.media_id = JSON.parse(response)["media_id"]
      # self.save
      begin
        self.update_column(:media_id, JSON.parse(response)["media_id"])
      rescue Exception => e
        self.errors.add(:base, JSON.parse(response)["errmsg"])   
      end    
    end  
    
    #{"type":"image","media_id":"k-r28uPnT28FjUrtlSlctLL3yDMicbvDguEY-vt3_kIW0gqDXqD4TCI3UxR84UxJ","created_at":1387941716}%  

  end
  

end
