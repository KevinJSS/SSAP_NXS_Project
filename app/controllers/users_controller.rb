class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[ show edit update ]

  def index
    @users = User.where.not(id: current_user.id)
  end

  def show
    redirect_to edit_user_registration_path if @user == current_user
    redirect_to edit_user_path(@user)
  end

  def edit
    redirect_to edit_user_registration_path if @user == current_user
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: "#{user_role} actualizado correctamente" }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:fullname, :id_card, :phone, :email, :job_position, :address, :role)
  end

  def user_role
    @user.role == "admin" ? "Administrador" : "Trabajador"
  end
end
