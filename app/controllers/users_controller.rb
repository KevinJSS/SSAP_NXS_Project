class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[ show edit update ]

  def index
    @users = User.where(role: "admin")
  end

  def collaborator_index
    @collaborator_users = User.where(role: "collaborator")
  end

  def show
    redirect_to edit_user_registration_path if @user == current_user
    redirect_to edit_user_path(@user)
  end

  def edit
    redirect_to edit_user_registration_path if @user == current_user
    @user.build_emergency_contact if @user.emergency_contact.nil?
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        validate_emergency_contact_data

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
    @user.role == "admin" ? "Administrador" : "Colaborador"
  end

  def validate_emergency_contact_data
    fullname = params[:user][:emergency_contact_attributes][:fullname]
    phone = params[:user][:emergency_contact_attributes][:phone]

    if @user.emergency_contact.nil?
      @em_contact = EmergencyContact.new(fullname: fullname, phone: phone, user: @user)
    else
      @user.emergency_contact.update(fullname: fullname, phone: phone)
      @em_contact = @user.emergency_contact
    end

    if fullname.blank? && phone.blank?
      return #emergency contact data not provided

    elsif !@em_contact.valid?
      flash[:alert] = "Información opcional del contacto de emergencia no fue proporcionada correctamente."
      return
    end

    @em_contact.save
  end
end
