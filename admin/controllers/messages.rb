Perfect::Admin.controllers :messages do
  get :index do
    @title = "Messages"
    @messages = Message.order('id DESC').page(params[:page])
    render 'messages/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'message')
    @message = Message.new
    render 'messages/new'
  end

  post :create do
    @message = Message.new(params[:message])
    if @message.save
      @title = pat(:create_title, :model => "message #{@message.id}")
      flash[:success] = pat(:create_success, :model => 'Message')
      params[:save_and_continue] ? redirect(url(:messages, :index)) : redirect(url(:messages, :edit, :id => @message.id))
    else
      @title = pat(:create_title, :model => 'message')
      flash.now[:error] = pat(:create_error, :model => 'message')
      render 'messages/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "message #{params[:id]}")
    @message = Message.find(params[:id])
    if @message
      render 'messages/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'message', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "message #{params[:id]}")
    @message = Message.find(params[:id])
    if @message
      if @message.update_attributes(params[:message])
        flash[:success] = pat(:update_success, :model => 'Message', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:messages, :index)) :
          redirect(url(:messages, :edit, :id => @message.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'message')
        render 'messages/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'message', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Messages"
    message = Message.find(params[:id])
    if message
      if message.destroy
        flash[:success] = pat(:delete_success, :model => 'Message', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'message')
      end
      redirect url(:messages, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'message', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Messages"
    unless params[:message_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'message')
      redirect(url(:messages, :index))
    end
    ids = params[:message_ids].split(',').map(&:strip)
    messages = Message.find(ids)
    
    if Message.destroy messages
    
      flash[:success] = pat(:destroy_many_success, :model => 'Messages', :ids => "#{ids.to_sentence}")
    end
    redirect url(:messages, :index)
  end
end
