class MainController < ApplicationController
  before_action :authenticate_user!

  def home
    #projects
    @projects = Project.count
    @closed_projects = Project.where(stage: :construction_inspection, stage_status: :delivered).length
    @active_projects = @projects - @closed_projects

    #activities
    start_date = Date.today - 1.month
    end_date = Date.today
    @month_activitites = Activity.where(date: start_date..end_date).count
    start_date = Date.today - 1.week
    end_date = Date.today
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
