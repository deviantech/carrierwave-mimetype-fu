require "carrierwave-mimetype-fu/version"

module CarrierWave
  module MimetypeFu
    extend ActiveSupport::Concern

    included do
      alias_method_chain :current_path, :mimetype_fu_ext
      
      begin
        require 'mimetype_fu'
      rescue LoadError => e
        e.message << ' (You may need to install the mimetype-fu gem)'
        raise e
      end
    end

    module ClassMethods
      def set_mimetype_fu_content_type(override=false)
        process :set_mimetype_fu_content_type => override
      end
    end

    # List from https://github.com/carrierwaveuploader/carrierwave/pull/949
    MIMETYPE_FU_GENERIC_CONTENT_TYPES = %w[      
      application-x/octet-stream

      application/
      application/*
      application/binary
      application/download
      application/download-file
      application/downloadfile
      application/force-download
      application/force_download
      application/oclet-stream
      application/octec-stream
      application/octect-stream
      application/octed-stream
      application/octet
      application/octet-binary
      application/octet-stream
      application/octet_stream
      application/octetstream
      application/octlet-stream
      application/save
      application/save-as
      application/stream
      application/unknown
      application/x-download
      application/x-file-download
      application/x-force-download
      application/x-forcedownload
      application/x-octet-stream
      application/x-octets
      application/x-octetstream
      application/x-unknown
      application/x-unknown-application-octet-stream
      application/x-unknown-content-type
      application/x-unknown-octet-stream

      applicaton/octet-stream

      attachment/octet-stream

      bad/type

      binary/
      binary/*
      binary/octec-stream
      binary/octet-stream
      binary/octet_stream
      binary/octetstream

      content-transfer-encoding/binary

      download/file
      download/test

      file/octet-stream
      file/unknown

      multipart/alternative
      multipart/form-data
      multipart/octet-stream

      octet/stream

      type/unknown

      unknown/
      unknown/application
      unknown/data
      unknown/unknown

      x-application/octet-stream
      x-application/octetstream

      x-unknown/octet-stream
      x-unknown/x-unknown
    ]

    def generic_content_type_for_mimetype_fu?(content_type)
      MIMETYPE_FU_GENERIC_CONTENT_TYPES.include? content_type
    end



    def mimetype_fu_ext
      MIME::Types[file.content_type].try(:first).try(:extensions).try(:first) || file.extension
    end
    
    def filename_with_mimetype_fu_ext
      file.send(:split_extension, file.original_filename)[0] + '.' + mimetype_fu_ext
    end
    
    def current_path_with_mimetype_fu_ext
      File.join(File.dirname(current_path_without_mimetype_fu_ext), filename_with_mimetype_fu_ext)
    end

    # Move cached file under new name so naive methods down the line will guess content type correctly
    def rename_file_with_proper_extension
      Rails.logger.fatal "[rename_file_with_proper_extension] File.basename(current_path_without_mimetype_fu_ext) != filename_with_mimetype_fu_ext: #{File.basename(current_path_without_mimetype_fu_ext) != filename_with_mimetype_fu_ext}"
      if File.basename(current_path_without_mimetype_fu_ext) != filename_with_mimetype_fu_ext
        Rails.logger.fatal "[rename_file_with_proper_extension] File.exists?(current_path_without_mimetype_fu_ext) && !File.exists?(current_path_with_mimetype_fu_ext): #{File.exists?(current_path) && !File.exists?(current_path_with_mimetype_fu_ext)}"
        if File.exists?(current_path_without_mimetype_fu_ext) && !File.exists?(current_path_with_mimetype_fu_ext)
          Rails.logger.fatal "[rename_file_with_proper_extension] MOVING FILE!"
          FileUtils.mv(current_path_without_mimetype_fu_ext, current_path_with_mimetype_fu_ext)
        end
      end 
    end
    

    ##
    # Changes the file content_type using the mimetype-fu gem
    #
    def set_mimetype_fu_content_type(override=false)
      if override || file.content_type.blank? || generic_content_type_for_mimetype_fu?(file.content_type)
        # cache_stored_file! unless cached! # Allows use with remote, previously-uploaded files (e.g. collecting meta on existing files)
        cache! unless File.exists?(file.path) # Allows use with remote, previously-uploaded files (e.g. collecting meta on existing files)        
        
        new_content_type = File.mime_type?( File.open(current_path_without_mimetype_fu_ext) ).split(';').first

        # TODO - REMOVE LOGGING STATEMENTS
        Rails.logger.fatal "[set_mimetype_fu_content_type] #{current_path} should be #{new_content_type}"

        if file.respond_to?(:content_type=)
          file.content_type = new_content_type
        else
          file.instance_variable_set(:@content_type, new_content_type)
        end
        
        # Now move the file to the new path
        rename_file_with_proper_extension

        # Overrwrite the file var with a new one based on the new proper file extension
        file = CarrierWave::SanitizedFile.new(current_path_with_mimetype_fu_ext)
        if file.respond_to?(:content_type=)
          file.content_type = new_content_type
        else
          file.instance_variable_set(:@content_type, new_content_type)
        end
        
        # Update the instance to act as if the file had been originally uploaded with the proper extension
        current_path = current_path_with_mimetype_fu_ext
        instance_variable_set '@file',              file
        instance_variable_set '@filename',          filename_with_mimetype_fu_ext
        instance_variable_set '@original_filename', filename_with_mimetype_fu_ext
      end
    rescue ::Exception => e
      raise CarrierWave::ProcessingError, I18n.translate(:"errors.messages.mimetype_fu_processing_error", e: e, default: 'Failed to process file with MimetypeFu. Original Error: %{e}')
    end

  end
end
