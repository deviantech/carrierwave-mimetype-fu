# CarrierWave::MimetypeFu

This allows to set file type with MimetypeFu instead of an extension.

To set correct file extension on resulting files on disk:

Add this to your uploader (or any other way)

    def filename
        if original_filename.present?
            ext = MIME::Types[file.content_type].nil? ? file.extension : MIME::Types[file.content_type].first.extensions.first
            split_extension(original_filename)[0] + '.' + ext
        end
    end


Based on the [carrierwave-magic](https://github.com/glebtv/carrierwave-magic) gem, but using [MimetypeFu](https://github.com/mattetti/mimetype-fu) rather than requiring installation of libmagic.

## Installation

Add this line to your application's Gemfile:

    gem 'carrierwave-mimetype-fu'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install carrierwave-mimetype-fu

## Usage

    class ImageUploader < CarrierWave::Uploader::Base
      include CarrierWave::MimetypeFu
      process :set_mimetype_fu_content_type
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
