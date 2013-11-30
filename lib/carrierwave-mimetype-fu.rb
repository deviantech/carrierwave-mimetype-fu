require "carrierwave-mimetype-fu/version"

module CarrierWave
  module MimetypeFu
    extend ActiveSupport::Concern

    included do
      alias_method_chain :cache!, :mimetype_fu_magic
      
      begin
        require 'mimetype_fu'
      rescue LoadError => e
        e.message << ' (You may need to install the mimetype-fu gem)'
        raise e
      end
    end

    def cache_with_mimetype_fu_magic!(new_file = sanitized_file)
      # Only step in on the initial file upload
      return cache_without_mimetype_fu_magic!(new_file) unless new_file.is_a?(ActionDispatch::Http::UploadedFile)
      
      begin
        # Collect information about the real content type
        real_content_type = File.mime_type?( File.open(new_file.path) ).split(';').first
        valid_extensions  = Array(MIME::Types[real_content_type].try(:first).try(:extensions))
        
        # Set proper content type, and update filename if current name doesn't match reach content type
        new_file.content_type = real_content_type
        new_file  = CarrierWave::SanitizedFile.new(new_file)
        base, ext = new_file.send(:split_extension, new_file.original_filename)
        ext = valid_extensions.first unless valid_extensions.include?(ext)
        
        new_file.instance_variable_set '@original_filename', [base, ext].join('.')
      rescue StandardError => e
        Rails.logger.warn "[carrierwave-mimetype-fu] Exception raised, not fixing image extension. #{e}" 
      ensure
        cache_without_mimetype_fu_magic!(new_file)
      end
    end

  end
end
