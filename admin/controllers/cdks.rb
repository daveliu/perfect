Perfect::Admin.controllers :cdks do
  get :index do
    @title = "Cdks"
    @cdks = Cdk.all
    render 'cdks/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'cdk')
    @cdk = Cdk.new
    render 'cdks/new'
  end

  post :create do
    @cdk = Cdk.new(params[:cdk])
    if @cdk.save
      @title = pat(:create_title, :model => "cdk #{@cdk.id}")
      flash[:success] = pat(:create_success, :model => 'Cdk')
      params[:save_and_continue] ? redirect(url(:cdks, :index)) : redirect(url(:cdks, :edit, :id => @cdk.id))
    else
      @title = pat(:create_title, :model => 'cdk')
      flash.now[:error] = pat(:create_error, :model => 'cdk')
      render 'cdks/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "cdk #{params[:id]}")
    @cdk = Cdk.find(params[:id])
    if @cdk
      render 'cdks/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'cdk', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "cdk #{params[:id]}")
    @cdk = Cdk.find(params[:id])
    if @cdk
      if @cdk.update_attributes(params[:cdk])
        flash[:success] = pat(:update_success, :model => 'Cdk', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:cdks, :index)) :
          redirect(url(:cdks, :edit, :id => @cdk.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'cdk')
        render 'cdks/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'cdk', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Cdks"
    cdk = Cdk.find(params[:id])
    if cdk
      if cdk.destroy
        flash[:success] = pat(:delete_success, :model => 'Cdk', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'cdk')
      end
      redirect url(:cdks, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'cdk', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Cdks"
    unless params[:cdk_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'cdk')
      redirect(url(:cdks, :index))
    end
    ids = params[:cdk_ids].split(',').map(&:strip)
    cdks = Cdk.find(ids)
    
    if Cdk.destroy cdks
    
      flash[:success] = pat(:destroy_many_success, :model => 'Cdks', :ids => "#{ids.to_sentence}")
    end
    redirect url(:cdks, :index)
  end
end
