# carrierwave-mimetype-fu changelog

## `0.3`

  * Replaces very old mimetype-fu with [Marcel](https://github.com/basecamp/marcel) to ensure we're checking against content type

## `0.0.2`

  * Also engage when given a remote file (CarrierWave::Uploader::Download::RemoteFile)

## `0.0.1`

  * Added initial functionality. Only engages on direct file upload (ActionDispatch::Http::UploadedFile)
