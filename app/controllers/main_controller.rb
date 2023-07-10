class MainController < ApplicationController
  before_action :authenticate_user!

  def home
    #projects
    @projects = Project.count
    @closed_projects = Project.where(stage: 8, stage_status: 2).length
    @active_projects = @projects - @closed_projects

    #activities
    start_date = Date.current.beginning_of_month
    end_date = Date.current.end_of_month
    @month_activitites = Activity.where(date: start_date..end_date).count

    start_date = Date.current.beginning_of_week
    end_date = Date.current.end_of_week
    @week_activitites = Activity.where(date: start_date..end_date).count
    
    @day_activitites = Activity.where(date: Date.today).count

    #collaborators
    @collaborators = User.where(role: :collaborator).count
    @active_collaborators = User.where(role: :collaborator, status: true).count
    @inactive_collaborators = @collaborators - @active_collaborators

    #admins
    @admins = User.where(role: :admin).count
    @active_admins = User.where(role: :admin, status: true).count
    @inactive_admins = @admins - @active_admins
  end
end
