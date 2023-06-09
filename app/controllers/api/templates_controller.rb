module Api
  # The few api endpoints for the tempates that should be moved to graphql
  class TemplatesController < ApiController
    require 'zip'

    skip_before_action :require_token, only: :export
    before_action :require_token_from_params, only: :export

    def upload_template_image
      return render json: { error: 'No file attached' }, status: :bad_request if params[:id].nil?

      template = Template.find(params[:id])
      file = File.open(params[:image], 'r')
      template.image.attach(io: file, filename: 'template image')
      return render json: { success: 'Uploaded image' } if template.save

      render json: { error: 'Couldnt save Template' }, status: :bad_request
    end

    def export
      templates = Template.where(team_id: current_user.team_id)
      return redirect_to templates_url, alert: 'Cannot export because there a templates with duplicate names.' if templates.map(&:name).uniq.length != templates.map(&:name).length

      filename = "#{current_user.team.name}-Templates-#{Time.now.to_i}.zip"
      Zip::File.open("/tmp/#{filename}", Zip::File::CREATE) do |zipfile|
        templates.each do |template|
          zipfile.mkdir(template.name)
          zipfile.get_output_stream("#{template.name}/template.html") { |f| f.puts template.body }
          zipfile.get_output_stream("#{template.name}/schema.yaml") { |f| f.puts template.template_schema.body }
          zipfile.get_output_stream("#{template.name}/UiSchema.yaml") { |f| f.puts template.template_schema.ui_schema }
        end
      end
      send_file "/tmp/#{filename}"
    end

    def import
      begin
        upload_time = Time.now.to_i
        name = params[:file].original_filename.split('.')[0] + "_uploaded_#{upload_time}.zip"
        path = File.join('tmp', name)
        extracted_path = path.split('.')[0] + "-#{upload_time}"

        File.open(path, 'wb') { |f| f.write(params[:file].read) }
        Zip::File.open(path) do |zip_file|
          # Handle entries one by one
          zip_file.each do |entry|
            entry.extract(extracted_path + '/' + entry.name)
          end
        end
        # iterate over the extracted directory
        Dir.each_child(extracted_path) do |template_dir|
          p template_dir
          template = Template.where(team_id: current_user.team_id).find_by(name: template_dir)
          if template
            # update existing one
            template_schema = template.template_schema
            template_schema.body = File.read("#{extracted_path}/#{template_dir}" + '/schema.yaml')
            template_schema.ui_schema = File.read("#{extracted_path}/#{template_dir}" + '/UiSchema.yaml')
            template_schema.save
            template.body = File.read("#{extracted_path}/#{template_dir}" + '/template.html')
            template.save!
          else
            # make a new one
            template = Template.new
            template.name = template_dir
            template.body = File.read("#{extracted_path}/#{template_dir}" + '/template.html')
            template.team_id = current_user.team_id
            template.save
            template_schema = TemplateSchema.new
            template_schema.template_id = template.id
            template_schema.body = File.read("#{extracted_path}/#{template_dir}" + '/schema.yaml')
            template_schema.ui_schema = File.read("#{extracted_path}/#{template_dir}" + '/UiSchema.yaml')
            template_schema.team_id = current_user.team_id
            template_schema.save!
          end
        end
      rescue StandardError => e
        return render json: { message: e.message }, status: :bad_request
      end
      render json: { message: 'Templates successfully imported.' }
    end

    private

    def require_token_from_params
      token = request.params[:apiToken]
      return render json: { error: 'Auth token missing' }, status: :forbidden unless token

      begin
        decoded_token = JWT.decode token, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS512' }
        @current_user = User.find(decoded_token[0]['user_id'])
      rescue StandardError => e
        render json: { error: 'Token verification error' }, status: :forbidden
      end
    end
  end
end
