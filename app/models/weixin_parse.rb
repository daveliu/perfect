#coding:utf-8
require 'builder'
class WeixinParse
  
  def self.news_msg(hash)
    builder = Builder::XmlMarkup.new
    datas = builder.xml do |b|    
      b.ToUserName(hash[:from_user])
      b.FromUserName(hash[:to_user])
      b.Articles(hash[:items])
      b.ArticleCount(hash[:items].count)            
    end  
    datas
  end
  
  def self.text_msg(hash)
    builder = Builder::XmlMarkup.new
    datas = builder.xml do |b|    
      b.ToUserName(hash[:from_user])
      b.FromUserName(hash[:to_user])
      b.CreateTime("#{Time.now}")
      b.Content(hash[:content])            
    end  
    datas
  end
  
  def self.text_parse(msg)
    wm = Message.where(:uid => msg['FromUserName'], :generated_image => nil).first
    if  wm.blank?
      wm = Message.create(:uid => msg['FromUserName'])
    end  
    wm.update_from_message(msg)      
    WeixinParse.text_msg(:from_user => msg['ToUserName'], :to_user =>  msg['FromUserName'], 
                   :content => wm.tips)
  end

  def self.image_parse(msg)

    wm = Message.where(:uid => msg['FromUserName'], :generated_image => nil).first
    if wm.nil? || wm.label.nil? ||  wm.content.nil? || wm.desc.nil? || wm.name.nil?            
      return  WeixinParse.text_msg(:from_user => msg['ToUserName'], :to_user =>  msg['FromUserName'], 
                     :content => "欢迎订阅，发送1开始进入不完美图片制作") 
    end                      
    
    begin
      wm.update_from_message(msg)    
      wm.generate_image!
            
      item =  Builder::XmlMarkup.new
      item.Title("wanmei")
      item.Discription("wanmei")
      item.PicUrl( BaseURL + wm.generated_image.url)
      item.Url( BaseURL + wm.generated_image.url)

      WeixinParse.news_msg(:from_user => msg['ToUserName'], :to_user =>  msg['FromUserName'], 
                   :items => [item])                        
    rescue Exception => e
      WeixinParse.text_msg(:from_user => msg['ToUserName'], :to_user =>  msg['FromUserName'], 
                     :content => "图片生成结果不完美，请再试一次")       
    end                        
  end


  def self.event_parse(msg)
    case msg.Event
    when 'subscribe' # 订阅
      WeixinParse.text_msg(:from_user => msg['ToUserName'], :to_user =>  msg['FromUserName'], 
                     :content => "欢迎订阅，发送1开始进入不完美图片制作")
    when 'unsubscribe' # 退订
      # 又少了名用户
    when 'CLICK' # 点击菜单
      menu_parse(msg)
    else
      WeixinParse.text_msg(:from_user => msg['ToUserName'], :to_user =>  msg['FromUserName'], 
                     :content => "欢迎订阅，发送1开始进入不完美图片制作")
    end
  end

  def self.menu_parse(msg)
    case msg.EventKey
    when 'profile'
      # ???
      Weixin.text_msg(msg.ToUserName, msg.FormUserName, '主人您的个人信息丢失啦~')
    else
      Weixin.text_msg(msg.ToUserName, msg.FromUserName, '您想来点什么？')
    end 
  end

  def self.msg_router(msg)
    case msg['MsgType']
    when 'text'
      text_parse(msg)
    when 'image'
      image_parse(msg)
    when 'location'
      location_parse(msg)
    when 'link'
      link_parse(msg)
    when 'event'
      event_parse(msg)
    when 'voice'
      voice_parse(msg)
    when 'video'
      video_parse(msg)
    else
      Weixin.text_msg(msg.ToUserName, msg.FromUserName, '作为一名程序猿，表示压力山大~~')
    end
  end

end