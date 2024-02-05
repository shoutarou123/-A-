class BasePointsController < ApplicationController
  before_action :set_base_point, only: [:edit, :update, :destroy]
  before_action :logged_in_user, only: [:index, :new, :create, :edit, :update, :destroy]
  before_action :admin_user, only: [:index, :new, :create, :edit, :update, :destroy]

  def index
    @base_points = BasePoint.all
  end

  def new
    @base_point = BasePoint.new
  end

  def create
    @base_point = BasePoint.new(base_params)
    if @base_point.save
      flash[:success] = "拠点が追加されました。"
      redirect_to base_points_path
    else
      flash[:danger] = "拠点の追加に失敗しました。"
      render :index
    end
  end

  def edit
  end

  def update
    if @base_point.update(base_params)
      flash[:success] = "拠点が更新されました。"
      redirect_to base_points_url(@base_point)
    else
      flash[:danger] = "拠点の更新に失敗しました。"
      redirect_to edit_base_point_path
    end
  end

  def destroy
    if @base_point.destroy
      flash[:success] = "拠点が削除されました。"
    else
      flash[:danger] = "拠点の削除に失敗しました。"
    end
    redirect_to base_points_path
  end

  private

  def set_base_point
    @base_point = BasePoint.find(params[:id])
  end

  def base_params
    params.require(:base_point).permit(:base_number, :base_name, :attendance_type)
  end

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "ログインしてください。"
      redirect_to login_url
    end
  end

  def admin_user
    redirect_to root_url unless logged_in? && current_user.admin?
  end
end

# ok