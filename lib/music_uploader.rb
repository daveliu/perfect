# encoding: utf-8

class MusicUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick
  # include CarrierWave::MiniMagick

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
        extension = file.extension.blank? ? "mp3" : file.extension
        "#{secure_token(10)}.#{extension}"
      end
    end
  end

  def secure_token(length=16)
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
  end

end
