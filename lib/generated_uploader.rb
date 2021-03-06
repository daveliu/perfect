# encoding: utf-8

class GeneratedUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick
  include CarrierWave::MiniMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  # include Sprockets::Helpers::RailsHelper
  # include Sprockets::Helpers::IsolatedHelper

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{get_last_dir_part(model.id)}"
  end
  
  def get_last_dir_part(modelid)
    p = modelid.to_s.rjust(9, '0')
    "#{p[0,3]}/#{p[3,3]}/#{p[6,3]}"
  end
  
  def default_url
    "/assets/" + [version_name, "default_room.png"].compact.join('_')
  end
  
  # def extension_white_list
  #   %w(jpg jpeg gif png bmp)
  # end
  
  def filename
    # if original_filename
    #   ext = File.extname(original_filename)
    #   fname = Digest::MD5.hexdigest(Time.now.to_s)
    #   @name ||= "#{fname}#{ext}"
    # end
    if original_filename.present?
      if model && model.read_attribute(:generated_image).present?
        model.read_attribute(:generated_image)
      else
        # ext = File.extname(original_filename)
        # fname = Digest::MD5.hexdigest(Time.now.to_s)
        # @name ||= "#{fname}#{ext}"
        extension = file.extension.blank? ? "png" : file.extension
        "#{secure_token(10)}.#{extension}"
      end
    end
  end

  def secure_token(length=16)
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

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

end
