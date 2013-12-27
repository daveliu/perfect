#coding:utf-8
require 'builder'
class WeixinParse
  
  WELCOME = "#不完美的完美#活动正在火热进行中，
发送字母“wm”开始制作属于您的不完美体，
还有机会赢魅族MX3和日本5天4夜豪华游哦！"
  
  def self.news_msg(hash)
    puts "--------------------#{hash}"
    builder = Builder::XmlMarkup.new
    datas = builder.xml do |b|    
      b.ToUserName(hash[:to_user])
      b.FromUserName(hash[:from_user])
      b.CreateTime("#{Time.now}")      
      b.MsgType('news')       
      b.ArticleCount(1)                
      b.Articles do |item|
        b.item do
          item.Title("魅族活动")
          item.Discription("COOL!快去晒晒你“不完美的完美”吧～分享到朋友圈，还有机会赢MX3和日本5天4夜豪华游哦！")
          item.PicUrl(BaseURL + hash[:picurl])
          item.Url(BaseURL + hash[:url])
        end
      end         
    end  
    datas
  end
  
  def self.text_msg(hash)
    builder = Builder::XmlMarkup.new
    datas = builder.xml do |b|    
      b.ToUserName(hash[:to_user])
      b.FromUserName(hash[:from_user])
      b.MsgType('text')      
      b.CreateTime("#{Time.now}")
      b.Content(hash[:content])            
    end  
    datas
  end
  
  def self.text_parse(msg)
    wm = Message.where(:uid => msg['FromUserName'], :generated_image => nil).first
    
    if msg['Content'] == "wm"
      if  wm.blank?
        wm = Message.create(:uid => msg['FromUserName'])
      end        
      WeixinParse.text_msg(:from_user => msg['ToUserName'], :to_user =>  msg['FromUserName'], 
                     :content => wm.tips)
    elsif msg['Content'] == "获奖名单"
      WeixinParse.text_msg(:from_user => msg['ToUserName'], :to_user =>  msg['FromUserName'], 
                     :content => "请打开http://wanmei.meizu.com/cheers查看获奖名单，谢谢参与！")      
    else                   
      if  wm.blank?    
          
        WeixinParse.text_msg(:from_user => msg['ToUserName'], :to_user =>  msg['FromUserName'], 
                     :content => WELCOME)
      else                         
        wm.update_from_message(msg)      
        WeixinParse.text_msg(:from_user => msg['ToUserName'], :to_user =>  msg['FromUserName'], 
                       :content => wm.tips)
      end                 
    end  
  end

  def self.image_parse(msg)

    wm = Message.where(:uid => msg['FromUserName'], :generated_image => nil).first
    puts "----------------------#{wm}"
    if wm.nil? || wm.label.blank? ||  wm.content.blank? || wm.desc.blank? || wm.name.blank?            
      return    WeixinParse.text_msg(:from_user => msg['ToUserName'], :to_user =>  msg['FromUserName'], 
                     :content => WELCOME)
    end                      
    
#    begin
      wm.update_from_message(msg)    
      wm.generate_image!
      
      generated_img = "#{Padrino.root}/public#{wm.generated_image.url}"    
      weixin_thumb_img = "#{Padrino.root}/public#{wm.generated_image.url}".sub(".png", 'weixin.png')    
      system("convert #{generated_img}  -gravity South  -crop 512x330+0+5   #{weixin_thumb_img}")
            
      # builder =  Builder::XmlMarkup.new
      # datas = builder.item do |b|          
      #   b.Title("wanmei")
      #   b.Discription("wanmei")
      #   b.PicUrl( BaseURL + wm.generated_image.url)
      #   b.Url( BaseURL + wm.generated_image.url)
      # end
      WeixinParse.news_msg(:from_user => msg['ToUserName'], :to_user =>  msg['FromUserName'], 
                   :picurl => wm.generated_image.url.sub(".png", 'weixin.png'), :url => "/cool_weixin/#{wm.token}")                        
    # rescue Exception => e
    #   WeixinParse.text_msg(:from_user => msg['ToUserName'], :to_user =>  msg['FromUserName'], 
    #                  :content => "图片生成结果不完美，请再试一次")       
    # end                        
  end


  def self.event_parse(msg)
    case msg['Event']
    when 'subscribe' # 订阅
      WeixinParse.text_msg(:from_user => msg['ToUserName'], :to_user =>  msg['FromUserName'], 
                     :content => "欢迎订阅魅族手机！
 
#不完美的完美#活动正在火热进行中，
发送字母“wm”开始制作属于您的不完美体，
还有机会赢魅族MX3和日本5天4夜豪华游哦！")
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