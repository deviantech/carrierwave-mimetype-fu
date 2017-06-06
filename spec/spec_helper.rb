# frozen_string_literal: true

require "rubygems"
require "bundler/setup"
require "rspec"
require "rails"

require "carrierwave"
require "carrierwave-mimetype-fu"

def file_path(*paths)
  File.expand_path(File.join(File.dirname(__FILE__), "fixtures", *paths))
end

def uploads_path(*paths)
  File.expand_path(File.join(File.dirname(__FILE__), "..", "uploads", *paths))
end

def uploaded_file(file)
  filename = File.basename(file.path)
  type = MIME::Types.type_for(filename).first
  ActionDispatch::Http::UploadedFile.new(tempfile: file,
                                         filename: filename,
                                         type:     type)
end

def create_file(filename, mode = "w")
  File.new(File.join(File.dirname(__FILE__), "fixtures", filename), mode)
end

def write_file(filename, data, mode = "wb")
  file = create_file(filename, mode)
  file.write(data)
  file.flush
  file
end
