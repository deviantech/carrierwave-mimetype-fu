require "carrierwave-mimetype-fu/version"

module CarrierWave
  module MimetypeFu
    extend ActiveSupport::Concern

    included do
      mod = Module.new do
        def cache!(new_file = sanitized_file)
          # Only step in on the initial file upload
          opened_file = case new_file.class.name
                          when 'CarrierWave::Uploader::Download::RemoteFile', 'CarrierWave::Downloader::RemoteFile' then
                            new_file.send(:file)
                          when 'ActionDispatch::Http::UploadedFile' then
                            File.open(new_file.path)
                          else
                            nil
                        end

          return super(new_file) unless opened_file


          begin
            # Collect information about the real content type
            real_content_type = Marcel::MimeType.for(opened_file).split(';').first
            valid_extensions  = Array( MimeMagic::TYPES[real_content_type]&.first )

            # Set proper content type, and update filename if current name doesn't match reach content type
            new_file              = CarrierWave::SanitizedFile.new(new_file)
            new_file.content_type = real_content_type
            base, ext             = new_file.send(:split_extension, new_file.original_filename)
            ext                   = valid_extensions.first unless valid_extensions.include?(ext)

            new_file.instance_variable_set '@original_filename', [base, ext].join('.')
          rescue StandardError => e
            Rails.logger.warn "[carrierwave-mimetype-fu] Exception raised, not fixing image extension. #{e}"
          ensure
            super(new_file)
          end
        end
      end

      prepend mod

      begin
        require 'marcel'
      rescue LoadError => e
        e.message << ' (You may need to install the marcel gem)'
        raise e
      end
    end
  end
end
