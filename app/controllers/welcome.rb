Perfect::App.controllers :welcome do
  register Padrino::Rendering  
  register Padrino::Helpers  
  
#  use Rack::Protection::AuthenticityToken, :except => "weixin"
    
  # get :index, :map => '/foo/bar' do
  #   session[:foo] = 'bar'
  #   render 'index'
  # end

  # get :sample, :map => '/sample/url', :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  # get :foo, :with => :id do
  #   'Maps to url '/foo/#{params[:id]}''
  # end

  # get '/example' do
  #   'Hello world!'
  # end
  
  get :index do
    render '/welcome/index'
  end
  
  get :new , :map => "new" do
    @message = Message.new
    render '/welcome/new'
  end
  
  post :create do
    @message = Message.find_by_token(params[:token])
    puts "------------------#{params[:message]}"
    params[:message][:content] =  params[:message][:content].values.join(" |perfect| ")
    params[:message][:desc] = params[:message][:desc].values.join(" |perfect| ")    
    if @message.update_attributes(params[:message])
      begin
        @message.generate_image!     
        redirect_to "/cool/#{@message.token}"           
      rescue Exception => e
        puts "-----------------#{e}"  
        flash.now[:notice] = "抱歉，生成图片的过程不太完美，请再试一次"
        render "/welcome/new" 
      end
            
    else
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
    @message = Message.find_by_token(params[:token])
    render '/welcome/cool'
  end  
  
  
  get :rules, :map => 'rules' do 
    render '/welcome/rules'
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
    
#     begin
       back_messages = WeixinParse.msg_router(message)     
       logger.info "返回: #{back_messages}"     
       back_messages  
     # rescue Exception => e
     #   logger.info "错误: #{e}"            
     #   WeixinParse.text_msg(:from_user => message['ToUserName'], :to_user =>  message['FromUserName'], 
     #                      :content => "欢迎订阅，发送1开始进入不完美图片制作")        
   #  end
     
  end  

end
