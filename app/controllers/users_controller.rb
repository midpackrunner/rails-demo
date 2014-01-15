class UsersController < ApplicationController
  before_action :find_user, only: [:destroy, :show, :edit, :update, :following, :followers]
  before_action :signed_in_user, only: [:index, :edit, :update, :following, :followers]
  before_action :before_update_user, only: [:update]
  before_action :before_edit_user, only: [:edit]
  before_action :before_destroy_user, only: [:destroy]
  before_action :before_new_or_create_user, only: [:new, :create]
  
  def index
    @users = User.paginate(page: params[:page])
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = 'Welcome to the Rails Demo!'
      redirect_to @user
    else
      render 'new'
    end
  end
  
  def destroy
    @user.destroy if @user
    flash[:success] = "#{@user.name} deleted"
    redirect_to users_url
  end
  
  def show
    @microposts = @user.microposts.paginate(page: params[:page])
  end
  
  def edit
  end
  
  def update
    if @user && @user.update_attributes(user_params)
      flash[:success] = "Profile updated!"
      redirect_to @user
    else
      flash.now[:error] = "Oops! Please check your profile settings below, then save again."
      render 'edit'
    end
  end
  
  def following
    @title = 'Following'
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end
  
  def followers
    @title = 'Followers'
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end
  
private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
  
  def find_user
    @user = User.find_by_id(params[:id])
  end
  
  def before_update_user
    redirect_to(root_url) unless current_user?(@user)
  end
  
  def before_edit_user
    redirect_to(edit_user_url(current_user)) unless current_user?(@user)
  end
  
  def before_destroy_user
    redirect_to(root_url) unless current_user.admin? && !current_user?(@user)
  end
  
  def before_new_or_create_user
    redirect_to(root_url) if !current_user.nil?
  end
  
end
