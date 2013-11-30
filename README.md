# CarrierWave::MimetypeFu

This allows to set file type with MimetypeFu rather than relying on the uploaded file's extension.

To update the saved file's filename to use to correct extension after uploading, call +apply_correct_extension_on_upload+ in the +filename+ method of your uploader:

    def filename
      apply_correct_extension_on_upload
    end

This will return the original filename with the correct extension in place.

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
