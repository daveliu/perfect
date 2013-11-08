Perfect::App.controllers :welcome do
  register Padrino::Rendering  
  register Padrino::Helpers  
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
  
  post :upload do
    @message = Message.new(:image => params[:image])    
    if @message.save
      "<textarea>upload_success('#{@message.image.url(:thumb)}', '#{@message.token}');</textarea>"      
    else
      "<textarea>upload_error('#{@message.errors.values.first.try(:last)}');</textarea>"                  
    end
  
  end  
  
  get :cool, :map => 'cool/:token' do 
    @message = Message.find_by_token(params[:token])
    render '/welcome/cool'
  end  
  get :rules, :map => 'rules' do 
    render '/welcome/rules'
  end  

end
