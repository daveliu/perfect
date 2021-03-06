#coding:utf-8
require 'builder'
class Weixin
  
  WELCOME = "输入开始答题，立即参加赢奖活动"
    
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
    uid = msg['FromUserName']
    user = User.find_or_create_by_uid(uid)
    if user.over_today?
      return Weixin.text_msg(:from_user => msg['ToUserName'], :to_user =>  msg['FromUserName'], 
                     :content => "每日只能参加一次活动，请明天再来")
                     
    end                 
    
    if msg['Content'] == "begin"
      Question.ask_uid(uid)
    else                   
      if user.last_question.present?        
        if user.answer_right?(msg)
          if user.over_today?                        
            cdk = Cdk.send_to(uid)
            return Weixin.text_msg(:from_user => msg['ToUserName'], :to_user =>  msg['FromUserName'], 
                          :content => "全部回答正确，恭喜你获得了今日的CDK #{cdk.content}")                         
          else              
            Question.ask_uid(uid)                          
          end          
        else
          Question.ask_uid(uid, "回答错误，从第一题重新开始")     
        end    

      else
        return  Weixin.text_msg(:from_user => msg['ToUserName'], :to_user =>  msg['FromUserName'], 
                       :content => "输入begin，立即参加赢奖活动")
      end    
    end  
  end


  def self.msg_router(msg)
    case msg['MsgType']
    when 'text'
      text_parse(msg)
    # when 'event'
    #   event_parse(msg)
    else
      Weixin.text_msg(msg.ToUserName, msg.FromUserName, '输入开始答题，立即参加赢奖活动')
    end
  end

end