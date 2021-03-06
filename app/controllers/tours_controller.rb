class ToursController < ApplicationController
  before_action :load_tour, only: [:edit, :show, :update, :destroy]

  def new
    @tour = Tour.new
  end

  def show
  end

  def create
    @tour = current_user.tours.build tour_params
    if @tour.save
      flash[:success] = t("text.success")
      redirect_to current_user
    else
      flash[:danger] = t("text.fails")
      redirect_to current_user
    end
  end

  def edit
  end

  def update
    if @tour.update tour_params
      flash[:success] = t("text.success")
      redirect_to current_user
    else
      flash[:danger] = t("text.fails")
      redirect_to current_user
    end
  end

  def destroy
    @tour.destroy
    flash[:success] = t("text.success")
    redirect_to current_user
  end

  private

  def tour_params
    params.require(:tour).permit :title, :content, :place_id, :time, :vehicle, :cost, image_attributes: [:id,
      :image_link, :imageable_id, :imageable_type, :_destroy]
  end

  def load_tour
    @tour = Tour.find_by id: params[:id]
  end
end
