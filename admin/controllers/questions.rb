Perfect::Admin.controllers :questions do
  get :index do
    @title = "Questions"
    @questions = Question.order('id DESC')
    render 'questions/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'question')
    @question = Question.new
    render 'questions/new'
  end

  post :create do
    @question = Question.new(params[:question])
    if @question.save
      @title = pat(:create_title, :model => "question #{@question.id}")
      flash[:success] = pat(:create_success, :model => 'Question')
      params[:save_and_continue] ? redirect(url(:questions, :index)) : redirect(url(:questions, :edit, :id => @question.id))
    else
      @title = pat(:create_title, :model => 'question')
      flash.now[:error] = pat(:create_error, :model => 'question')
      render 'questions/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "question #{params[:id]}")
    @question = Question.find(params[:id])
    if @question
      render 'questions/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'question', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "question #{params[:id]}")
    @question = Question.find(params[:id])
    if @question
      if @question.update_attributes(params[:question])
        flash[:success] = pat(:update_success, :model => 'Question', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:questions, :index)) :
          redirect(url(:questions, :edit, :id => @question.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'question')
        render 'questions/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'question', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Questions"
    question = Question.find(params[:id])
    if question
      if question.destroy
        flash[:success] = pat(:delete_success, :model => 'Question', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'question')
      end
      redirect url(:questions, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'question', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Questions"
    unless params[:question_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'question')
      redirect(url(:questions, :index))
    end
    ids = params[:question_ids].split(',').map(&:strip)
    questions = Question.find(ids)
    
    if Question.destroy questions
    
      flash[:success] = pat(:destroy_many_success, :model => 'Questions', :ids => "#{ids.to_sentence}")
    end
    redirect url(:questions, :index)
  end
end
