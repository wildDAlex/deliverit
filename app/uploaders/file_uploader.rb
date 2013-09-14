# encoding: utf-8
require 'carrierwave/processing/mime_types'

class FileUploader < CarrierWave::Uploader::Base

  before :cache, :save_original_filename

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick
  include CarrierWave::MimeTypes
  process :set_content_type

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  #The following will generate UUID filenames in the format like 1df094eb-c2b1-4689-90dd-790046d38025.jpg
  def filename
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    #"uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    case Rails.env
      when 'production'
        Rails.root.join('..', '..', 'shared', 'uploads', "#{model.created_at.year}", "#{model.created_at.month}", "#{model.created_at.day}", "#{model.id}").to_s
      when 'development', 'test'
        Rails.root.join('uploads', "#{model.created_at.year}", "#{model.created_at.month}", "#{model.created_at.day}", "#{model.id}").to_s
    end
  end

  def cache_dir
    Rails.root.join('tmp', 'uploads', 'cache', "#{model.id}").to_s
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

  protected
  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end

  def save_original_filename(file)
    model.original_filename ||= file.original_filename if file.respond_to?(:original_filename)
  end

end
