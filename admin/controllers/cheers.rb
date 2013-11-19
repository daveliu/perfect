Perfect::Admin.controllers :cheers do
  get :index do
    @title = "Cheers"
    @cheers = Cheer.all
    render 'cheers/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'cheer')
    @cheer = Cheer.new
    render 'cheers/new'
  end

  post :create do
    @cheer = Cheer.new(params[:cheer])
    if @cheer.save
      @title = pat(:create_title, :model => "cheer #{@cheer.id}")
      flash[:success] = pat(:create_success, :model => 'Cheer')
      params[:save_and_continue] ? redirect(url(:cheers, :index)) : redirect(url(:cheers, :edit, :id => @cheer.id))
    else
      @title = pat(:create_title, :model => 'cheer')
      flash.now[:error] = pat(:create_error, :model => 'cheer')
      render 'cheers/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "cheer #{params[:id]}")
    @cheer = Cheer.find(params[:id])
    if @cheer
      render 'cheers/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'cheer', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "cheer #{params[:id]}")
    @cheer = Cheer.find(params[:id])
    if @cheer
      if @cheer.update_attributes(params[:cheer])
        flash[:success] = pat(:update_success, :model => 'Cheer', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:cheers, :index)) :
          redirect(url(:cheers, :edit, :id => @cheer.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'cheer')
        render 'cheers/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'cheer', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Cheers"
    cheer = Cheer.find(params[:id])
    if cheer
      if cheer.destroy
        flash[:success] = pat(:delete_success, :model => 'Cheer', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'cheer')
      end
      redirect url(:cheers, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'cheer', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Cheers"
    unless params[:cheer_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'cheer')
      redirect(url(:cheers, :index))
    end
    ids = params[:cheer_ids].split(',').map(&:strip)
    cheers = Cheer.find(ids)
    
    if Cheer.destroy cheers
    
      flash[:success] = pat(:destroy_many_success, :model => 'Cheers', :ids => "#{ids.to_sentence}")
    end
    redirect url(:cheers, :index)
  end
end
