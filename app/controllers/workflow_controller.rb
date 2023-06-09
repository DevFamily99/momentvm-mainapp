class WorkflowController < ApplicationController
  require "translation_service"

  class DeadlineError < StandardError
  end
  rescue_from DeadlineError, with: :deadline_empty

  # Start the workflow with a form to select pages to validate
  def validate_pages_start
    @pages = Page.by_team(current_user).where(translation_status: [:not_set, nil])
    if @pages.count == 0
      redirect_to page_folders_path, notice: "All translations already validated"
      return
    end
    @pages_newer = @pages.where("updated_at > ?", Date.today - 1).order(updated_at: :desc)
    @pages_older = @pages - @pages_newer
  
    @pages_older = @pages.where("updated_at < ?", Date.today - 1).order(updated_at: :desc).paginate(:page => params[:page], :per_page => 15)
  end

  # POST
  # Process selected pages
  def validate_pages
    errors = []
    messages = []
    pages_to_change = helpers.pages_from_params(params[:pages])
    pages_to_change.each do |page_id|
      page = Page.find(page_id)
      page.send_to_translation_validation do |error|
        if error != nil
          errors << "Could not send #{page.id} to validation"
          next
        end
      end
      if page.save
        messages << "Page #{page.name} saved"
      else
        errors << "Page #{page.name} could not be saved"
      end
    end
    if errors.count == 0
      redirect_to workflow_send_translations_start_path, notice: messages
    else
      puts "Errors with page validation: #{errors}"
      redirect_to page_folders_path, alert: errors
    end
  end

  # Form
  def send_translations_start
    @pages = Page.by_team(current_user).where(translation_status: :sent_for_validation)
    if @pages.count == 0
      redirect_to page_folders_path, notice: "No pages to send"
      return
    end
    @target_languages = Setting.by_team(current_user).find_by_name("target-languages")
    if @target_languages.nil?
      redirect_to page_folders_path, alert: "Target languages is missing. Create it in settings."
      return
    else
      @target_languages = YAML.load(@target_languages.body)
    end
  end

  def send_translations
    deadline = Time.parse(params[:deadline]).iso8601
    project_title = params[:project_title]
    unless project_title
      redirect_to workflow_send_translations_start_path, alert: "Project name can not be empty"
      return
    end

    raise DeadlineError if deadline == ""
    unless helpers.deadline_valid? deadline
      redirect_to workflow_send_translations_start_path, alert: "Deadline not valid"
      return
    end
    page_ids = helpers.pages_from_params(params[:pages])
    target_locales = helpers.locales_from_params(params[:locales])
    if target_locales.empty?
      redirect_to page_folders_path, alert: "Target Locales list is emtpy"
    end
    service = TranslationService.new
    pages = Page.where(id: page_ids)
    puts "Sending pages to translation: #{pages.pluck(:id)}"
    service.send_translations_as_project(pages: pages, target_locales: target_locales, deadline: deadline, project_title: project_title) do |error_response|
      if error_response.nil?
        pages.each do |page|
          page.translation_status = :waiting_for_translation
          page.translation_project_id = JSON.parse(service.body)["translation_request"]
          page.save
        end
        redirect_to page_folders_path, notice: "Sent successfully"
        return
      else
        redirect_to page_folders_path, alert: "Errors: #{error_response.message}. Check if some of the translations contain errors"
        return
      end
    end
  end

  def check_finished_translations_start
    service = TranslationService.new
    service.check_for_finalized_translations do |finalized_ids|
      puts "finalized ids: #{finalized_ids}"
    end
    redirect_to page_folders_path, notice: "Done"
  end

  def reset_translation_status
    @page.translation_status = nil
    if @page.save
      redirect_to page_folders_path, notice: "Translation status reset"
    else
      redirect_to page_folders_path, alert: "Error resetting Translation status"
    end
  end
  
  def translation_projects
  end

  private

  def deadline_empty(exception)
    redirect_to workflow_send_translations_start_path, alert: "Deadline not valid"
  end


end
