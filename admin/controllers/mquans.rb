Perfect::Admin.controllers :mquans do
  get :index do
    @title = "Mquans"
    @mquans = Mquan.order('id DESC').page(params[:page])    
    render 'mquans/index'
  end
  
  post :import do
    Mquan.import(params[:file])
    redirect 'mquans/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'mquan')
    @mquan = Mquan.new
    render 'mquans/new'
  end

  post :create do
    @mquan = Mquan.new(params[:mquan])
    if @mquan.save
      @title = pat(:create_title, :model => "mquan #{@mquan.id}")
      flash[:success] = pat(:create_success, :model => 'Mquan')
      params[:save_and_continue] ? redirect(url(:mquans, :index)) : redirect(url(:mquans, :edit, :id => @mquan.id))
    else
      @title = pat(:create_title, :model => 'mquan')
      flash.now[:error] = pat(:create_error, :model => 'mquan')
      render 'mquans/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "mquan #{params[:id]}")
    @mquan = Mquan.find(params[:id])
    if @mquan
      render 'mquans/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'mquan', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "mquan #{params[:id]}")
    @mquan = Mquan.find(params[:id])
    if @mquan
      if @mquan.update_attributes(params[:mquan])
        flash[:success] = pat(:update_success, :model => 'Mquan', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:mquans, :index)) :
          redirect(url(:mquans, :edit, :id => @mquan.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'mquan')
        render 'mquans/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'mquan', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Mquans"
    mquan = Mquan.find(params[:id])
    if mquan
      if mquan.destroy
        flash[:success] = pat(:delete_success, :model => 'Mquan', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'mquan')
      end
      redirect url(:mquans, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'mquan', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Mquans"
    unless params[:mquan_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'mquan')
      redirect(url(:mquans, :index))
    end
    ids = params[:mquan_ids].split(',').map(&:strip)
    mquans = Mquan.find(ids)
    
    if Mquan.destroy mquans
    
      flash[:success] = pat(:destroy_many_success, :model => 'Mquans', :ids => "#{ids.to_sentence}")
    end
    redirect url(:mquans, :index)
  end
end
