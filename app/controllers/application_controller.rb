require 'errors'

class ApplicationController < ActionController::Base
  include Response

 # http_basic_authenticate_with name: BASIC_AUTH_USERNAME, password: BASIC_AUTH_PASSWORD if Rails.env.production?
  before_action :require_login
  before_action :set_page_archive_folder
  before_action :set_page_root_folder
  before_action :set_paper_trail_whodunnit, :set_current_user

  private

  def not_authenticated
    redirect_to login_path # , alert: "Please login"
  end

  def set_page_archive_folder
    return if current_user.nil?

    @page_archive_folder = PageFolder.where(name: 'Archive', team: current_user.team).first # Reserved for archive
  end

  def set_page_root_folder
    return if current_user.nil?

    @page_root_folder = PageFolder.where(team: current_user.team, page_folder_id: nil).first
  end

  def set_current_user
    current_user
  end
end
