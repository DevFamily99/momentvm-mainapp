# An asset like an image
class Asset < ApplicationRecord
  require 'mini_magick'
  require 'request'
  include Rails.application.routes.url_helpers
  include PgSearch::Model

  multisearchable(against: [:id, :name], additional_attributes: ->(asset) { { team_id: asset.team_id } })

  belongs_to :asset_folder, optional: true
  belongs_to :team
  validates :name, uniqueness: { scope: :team_id }, format: /[a-zA-Z0-9]+/
  has_one_attached :image
  has_one :image_attachment,
          -> { where(name: 'image') },
          class_name: 'ActiveStorage::Attachment', as: :record, inverse_of: :record, dependent: false
  has_one :image_blob, through: :image_attachment, class_name: 'ActiveStorage::Blob', source: :blob

  # File ending directory friends
  def file_ending
    case image.content_type
    when 'image/jpeg'
      '.jpg'
    when 'image/gif'
      '.gif'
    when 'image/png'
      '.png'
    when 'image/svg+xml'
      '.svg'
    else
      ''
    end
  end

  def thumbnail
    return 'error' if image.nil?
    return '' if image.attachment.nil?

    if image.variable?
      variant = image.variant(resize_to_fill: [200, 200])
      url_for(variant)
    else
      url_for(image.blob)
    end
  end

  def variants(variant_settings)
    variants = []
    # value is a bunch of options to resize etc
    variant_settings.each do |image_size, value|
      variant_option = {}
      variant_option[:name] = image_size.to_sym
      variant_option[:file_ending] = file_ending
      begin
        # skip image processing if its a gif or inline svg
        url = if image.blob.content_type == 'image/gif' || image.blob.content_type == 'image/svg+xml'
                url_for(image)
              else
                url_for(image.variant(apply: value))
              end
      rescue StandardError => e
        url = ''
      end
      variant_option[:url] = url
      variants << variant_option
    end
    variants
  end

  # New version for dynamic images
  # Uploads all variants to the WebDAV
  def upload_dynamic_variant(instance:, dynamic_images:, team:)
    return if dynamic_images.nil?
    return if dynamic_images.empty?

    # Find dynamic variants of that assets which are needed
    dynamic_image_variants = dynamic_images.find_all { |f| f[:name] == name }
    return if dynamic_image_variants.empty?

    setting_variants = SettingService.load_image_sizes_from_db(team)
    dynamic_image_variants.each do |variant|
      filename = variant['imageName']
      sizeName = variant['imageSize']
      commands = setting_variants[sizeName]
      file = Tempfile.new(filename)
      file.binmode
      commands['coalesce'] = true if image.blob.content_type == 'image/gif'
      variant_blob = image.call(apply: value).processed
      file.write variant_blob.service.download(variant_blob.key)
      file.close
      file_ending = self.file_ending
      puts "upload dynamic variant #{filename}__#{sizeName}#{file_ending} to #{instance}"
      upload(file.path, "#{filename}__#{sizeName}#{file_ending}", instance)
    end
  end

  # Legacy. Used for image type v1
  # Uploads all variants to the WebDAV
  def upload_variants(instance)
    puts "upload variants to #{instance}"
    filename = image.blob.filename.to_s
    file = Tempfile.new(image.record.name)
    file.binmode
    begin
      file.write image.download
    rescue StandardError => e
      puts "#{name}, id:#{id}, Aws::S3::Errors::NoSuchKey error #{e}"
      return
    end
    file.close
    variants = {
      high: { cmd: '1200x1200', prefix: '' },
      large: { cmd: '900x900', prefix: 'l_' },
      medium: { cmd: '800x800', prefix: 'm_' }
    }
    variants.each do |_variant, data|
      image = MiniMagick::Image.open(file.path)
      image.coalesce if image.type == 'GIF'
      image.resize data[:cmd]
      # image.format "jpg"
      # image.write "output.jpg"
      upload(image.path, "#{data[:prefix]}#{filename}", instance)
    end
  end

  def self.by_team(current_user)
    Asset.where(team_id: current_user.team_id)
  end

  # New method
  def upload(file_name:, variant_name:, commands:, publishing_target:)
    temp_file = Tempfile.new(file_name)
    temp_file.binmode
    commands['coalesce'] = true if image.blob.content_type == 'image/gif'
    begin
      variant_blob = if image.blob.content_type == 'image/gif'
                       image
                     else
                       image.variant(commands).processed
                     end
      temp_file.write variant_blob.service.download(variant_blob.key)
    rescue StandardError => e
      puts "AWS error for #{name} #{e}"
      return
    end
    temp_file.rewind
    file_ending = self.file_ending
    puts "uploading: #{file_name} to: #{publishing_target.name}"
    uri = URI.parse(publishing_target.webdav_path)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.ssl_version = :TLSv1_2
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    # puts uri.inspect
    request = Net::HTTP::Put.new("#{uri.request_uri}/#{file_name}")
    request.body_stream = temp_file.to_io
    request['Content-Type'] = 'multipart/form-data'
    request.add_field('Content-Length', temp_file.size)
    request.basic_auth(publishing_target.webdav_username, publishing_target.webdav_password)
    response = http.request(request)
    response_code = response.code.to_i
    temp_file.close
    temp_file = nil
    if response_code == 201 || response_code == 204
      puts "WebDAV file created (#{response_code})"
    else
      puts "Didnt save file on WebDAV. #{response} #{response.code}"
    end
    response
  end

  class Transformer
    attr_reader :transformations

    def initialize(transformations)
      @transformations = transformations
    end

    # Applies the transformations to the source image in +file+, producing a target image in the
    # specified +format+. Yields an open Tempfile containing the target image. Closes and unlinks
    # the output tempfile after yielding to the given block. Returns the result of the block.
    def transform(file, format:)
      output = process(file, format: format)

      begin
        yield output
      ensure
        output.close!
      end
    end

    private

    # Returns an open Tempfile containing a transformed image in the given +format+.
    # All subclasses implement this method.
    def process(_file, format:)
      #:doc:
      raise NotImplementedError
    end
  end
  class MiniMagickTransformer < Transformer
    private

    def process(file, format:)
      image = MiniMagick::Image.new(file.path, file)

      transformations.each do |name, argument_or_subtransformations|
        image.mogrify do |command|
          if name.to_s == 'combine_options'
            argument_or_subtransformations.each do |subtransformation_name, subtransformation_argument|
              pass_transform_argument(command, subtransformation_name, subtransformation_argument)
            end
          else
            pass_transform_argument(command, name, argument_or_subtransformations)
          end
        end
      end

      image.format(format) if format

      image.tempfile.tap(&:open)
    end

    def pass_transform_argument(command, method, argument)
      if argument == true
        command.public_send(method)
      elsif argument.present?
        command.public_send(method, argument)
      end
    end
  end
end
