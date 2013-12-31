Perfect::App.controllers :welcome do
  register Padrino::Rendering  
  register Padrino::Helpers  
    
  get :index do
    @body_class = "container_index"
    render '/welcome/index'
  end
  
  get :new , :map => "new" do
    @body_class = "container_myim"    
    @message = Message.new
    render '/welcome/new'
  end
  
  post :create do
    puts "------------------#{params[:message]}"
    params[:message][:content]['3'] = "不善交际" if params[:message][:content]['3'].blank?
    params[:message][:content]['4'] = "没有背景" if params[:message][:content]['4'].blank?
     params[:message][:desc]['2'] = "魅族手机用户"    if params[:message][:desc]['2'].blank?    
    params[:message][:content] =  params[:message][:content].values.join(" |perfect| ")
    params[:message][:desc] = params[:message][:desc].values.join(" |perfect| ")    
    
    if params[:token].present?
      @message = Message.find_by_token(params[:token])
      params[:message][:label] = "偏执狂"   if params[:message][:label].blank?
      params[:message][:name] = "黄章" if params[:message][:name].blank?    
      @message.update_attributes(params[:message])      
    else
      @message = Message.new params[:message]
      @message.label = "偏执狂"   if @message.label.blank?
      @message.name = "黄章"   if @message.name.blank? 
      @message.image =  File.open("#{Padrino.root}/public/images/default.png") if @message.image.blank?
      puts "------------------------#{@message.label}"
      @message.save      
    end    
          
    begin
      @message.generate_image!     
      redirect_to "/cool/#{@message.token}"           
    rescue Exception => e
      puts "-----------------#{e}"  
      flash.now[:notice] = "抱歉，生成图片的过程不太完美，请再试一次"
      render "/welcome/new" 
    end

    
  end  
  
  # get '/' do
  #   send_file 'foo.png'
  # end
  
  post :upload do
    @message = Message.new(:image => params[:image])    

    begin
      if @message.save
        "<textarea>upload_success('#{@message.image.url(:thumb)}', '#{@message.token}');</textarea>"      
      else
        "<textarea>upload_error('#{@message.errors.values.first.try(:last)}');</textarea>"                  
      end
    rescue Exception => e
      "<textarea>upload_error('上传不太完美，请再试一次');</textarea>"                        
    end      
  
  end  
  
  get :cool, :map => 'cool/:token' do 
    @body_class = "container_comp"            
    
    @message = Message.find_by_token(params[:token])
    render '/welcome/cool'
  end  
  
  get :cool_weixin, :map => 'cool_weixin/:token' do 
    @message = Message.find_by_token(params[:token])
    render '/welcome/cool_weixin', :layout => false
  end  
  
  
  get :rules, :map => 'rules' do 
    @body_class = "container_rule"        
    render '/welcome/rules'
  end  
  
  get :cheers, :map => 'cheers' do 
    @body_class = "container_rule"        
    @cheers = Cheer.order("id desc")
    render '/welcome/cheers'
  end  
  
  get :weixin, :map => 'weixin' do 
    echoStr = params[:echostr]
    signature = params[:signature]
    timestamp = params[:timestamp]
    nonce = params[:nonce]
    token = "g3k1aab4"
    tmpArr = [token, timestamp, nonce]
    tmpArr = tmpArr.sort
    tmpStr = tmpArr.join
    tmpStr = Digest::SHA1.hexdigest(tmpStr)
    if tmpStr == signature
      echoStr
    else
      "error"
    end         
  end  
  
  post :weixin, :csrf_protection => false, :map => 'weixin' do 
     content_type :xml, 'charset' => 'utf-8'
     
     req = Rack::Request.new(env)
     
     body = req.body.read.gsub("\n" , "")
     message = MultiXml.parse(body)['xml']
     logger.info("-------------------#{message}")
    
    wm =  WeixinMessage.where(:message_id => message['MsgId']).first
    if  wm.blank?
      WeixinMessage.create(:message_id => message['MsgId'])
      back_messages = Weixin.msg_router(message)     
      logger.info "返回: #{back_messages}"     
      back_messages  
    else
      return true  
    end
#     begin

     # rescue Exception => e
     #   logger.info "错误: #{e}"            
     #   WeixinParse.text_msg(:from_user => message['ToUserName'], :to_user =>  message['FromUserName'], 
     #                      :content => "欢迎订阅，发送1开始进入不完美图片制作")        
   #  end
    end  

end
