class MainController < ApplicationController
  # The `before_action` callback method ensures that the user is authenticated
  # before accessing any action in this controller. It helps enforce the requirement
  # for a user to be logged in before interacting with the `MainController`.
  before_action :authenticate_user!

  # The `home` action is responsible for rendering the homepage/dashboard view.
  # It retrieves various data and assigns them to instance variables that can be
  # accessed within the corresponding view template.
  def home
    #projects
    @projects = Project.count
    @closed_projects = Project.where(stage: 8, stage_status: 2).length
    @active_projects = Project.where.not(stage: 8).length

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
