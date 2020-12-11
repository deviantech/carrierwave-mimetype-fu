# frozen_string_literal: true

require "spec_helper"

describe CarrierWave::MimetypeFu do
  let(:uploader_class) do
    Class.new(CarrierWave::Uploader::Base) do
      include CarrierWave::MimetypeFu
    end
  end
  let(:uploader) { uploader_class.new }

  before do
    uploader.cache!(file)
  end

  after { FileUtils.rm_rf(uploads_path) }

  describe "#cache!" do
    before do
      allow(CarrierWave).to receive(:generate_cache_id).and_return("1369894322-345-1234-2255")
    end

    shared_examples "have an extension of" do |ext|
      it "have an extension of #{ext}" do
        expect(File.extname(uploader.file.original_filename)).to eq(ext)
      end
    end

    shared_examples "have a mime type of" do |mimetype|
      it "have a mime type of #{mimetype}" do
        expect(uploader.file.content_type).to eq(mimetype)
      end
    end

    describe "with a zero filelength" do

      let(:file) { uploaded_file(create_file("file.empty")) }

      include_examples "have an extension of", ""
      include_examples "have a mime type of", "inode/x-empty"
    end

    describe "with correct extension and content" do

      let(:file) { uploaded_file(write_file("file.png", "\211PNG\r\n\032\n", "wb")) }

      include_examples "have an extension of", ".png"
      include_examples "have a mime type of", "image/png"
    end

    describe "with only correct content" do

      let(:file) { uploaded_file(write_file("file", "\211PNG\r\n\032\n", "wb")) }

      include_examples "have an extension of", ".png"
      include_examples "have a mime type of", "image/png"
    end

    describe "with an unknown extension and content" do

      let(:file) { uploaded_file(write_file("file.unknown", "\211Random\r\n\032\n", "wb")) }

      include_examples "have an extension of", ".bin"
      include_examples "have a mime type of", "application/octet-stream"
    end

    describe "with wrong extension", :focus do

      let(:file) { uploaded_file(File.new(file_path("ruby.gif"))) }

      include_examples "have an extension of", ".png"
      include_examples "have a mime type of", "image/png"
    end

    describe "with correct extension" do
      let(:file) { uploaded_file(File.new(file_path("bork.txt"))) }

      include_examples "have an extension of", ".txt"
      include_examples "have a mime type of", "text/plain"
    end


    describe "without extension" do
      let(:file) { uploaded_file(File.new(file_path("ruby"))) }

      include_examples "have an extension of", ".png"
      include_examples "have a mime type of", "image/png"
    end
  end
end
