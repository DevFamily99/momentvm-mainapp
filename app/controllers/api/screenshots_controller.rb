# frozen_string_literal: true

class Api::ScreenshotsController < Api::ApiController
  # skip jwt token
  skip_before_action :require_token
  before_action :check_token

  def missing_images
    pages = Page
            .where(screenshot_status: [:waiting, :outdated])
            .order(updated_at: :desc)
            .map(&:id)
    render json: pages.compact
  end

  def schedules_to_screenshot
    render json: Schedule.where(screenshot_status: [:waiting, :outdated])
  end

  def upload_image
    page = Page.find(params[:page_id])
    if attach_base64_image(page, params[:image])
      page.update(screenshot_status: :up_to_date)
      render json: { message: 'created', status: :ok }
    else
      render json: { message: 'not created', status: :unprocessable_entity, error_message: page.errors }
    end
  end

  def upload_schedule_image
    schedule = Schedule.find(params[:schedule_id])
    if attach_base64_image(schedule, params[:image])
      schedule.update(screenshot_status: :up_to_date)
      render json: { message: 'created', status: :ok }
    else
      render json: { message: 'not created', status: :unprocessable_entity, error_message: page.errors }
    end
  end

  def template_thumbnail
    page_module = PageModule.find(params[:page_module_id])
    page = Page.find(params[:page_id])
    Templates::GenerateThumbnail.call(page_module: page_module, page: page)
    render json: { message: 'Thumbnail saved', status: :ok }
  end

  private

  def check_token
    return true if Rails.env.development?

    request_key = request.headers['SCREENSHOT-SERVICE-KEY']
    unless request_key && request_key == ENV['SCREENSHOT-SERVICE-KEY']
      puts 'Error: The keys dont match'
      puts "Provided: #{request_key} Expected: #{ENV['SCREENSHOT-SERVICE-KEY']}"
      return render status: :forbidden, json: {
        status: :forbidden,
        reason: :header_no_match
      }
    end
    true
  end

  def attach_base64_image(page, image)
    # Process the file, decode the base64 encoded file
    decoded_file = Base64.decode64(image)
    filename = 'image.png' # this will be used to create a tmpfile and also, while setting the filename to attachment
    tmp_file = Tempfile.new(filename) # This creates an in-memory file
    tmp_file.binmode # This helps writing the file in binary mode.
    tmp_file.write decoded_file
    tmp_file.rewind

    page.thumbnail.attach(io: tmp_file, filename: filename) # attach the created in-memory file, using the filename defined above
    page.save

    tmp_file.unlink # deletes the temp file
    true
  rescue StandardError => e
    false
  end
end
