
require_relative '../lib/7zrb'

describe Ruby7z do
  # Brittle test - the test_files must exist
  let(:test_files) { ["/home/leej/Downloads/7zt/hs2.mkv", "/home/leej/Downloads/7zt/hs2.mkv"] }
  let(:test_file) { "/home/leej/Downloads/7zt/hs1.mkv" }
  let(:target) { "/home/leej/RSTEST.zip" }
  let(:r7z) { Ruby7z.new }

  describe :initialize do
    it "takes a stringlike filename" do
      Ruby7z.new(test_file).should_not eq nil
    end

    it "accepts zero parameters" do 
      Ruby7z.new().should_not eq nil
    end

    it "accepts an array of parameters" do 
      Ruby7z.new(test_files).should_not eq nil
    end

  end

  describe :add do
    it "accepts an array of filenames" do 
      r7z.add(test_files)
      test_files.each { |f| r7z.filelist.include?(f).should eq true }
    end

    it "accepts a single filename" do
      r7z.add(test_file)
      r7z.filelist.include?(test_file).should eq true 
    end
  end

  describe :compress do
    before(:each) { r7z.add(test_files) }

    it "returns true on success" do
      r7z.compress(target).should eq true
    end

    it "creates the target zip file" do
      r7z.compress(target)
      File.exist?(target).should eq true
    end
  end

  describe :in_progress? do
    before(:each) { r7z.add(test_files) }

    it "returns true while creating a zip, false otherwise" do
      t = Thread.new { r7z.compress(target) }
      sleep 0.5 # small sleep to allow compression to start
      r7z.in_progress?(target).should eq true
      t.join
      r7z.in_progress?(target).should eq false
    end
  end

  describe :is_valid_archive? do
    before(:all) do 
      r7z = Ruby7z.new
      r7z.compress(target)
      r7z.add(test_files) 
    end

    it "returns true if the archive is valid" do
      r7z.is_valid_archive?(target).should eq true
    end

    it "returns false if the archive does not exist" do
      r7z.is_valid_archive?("/home/leej/this_does_not_exist.zip").should eq false
    end

    it "returns false if a file in the filelist does not exist" do
      r7z.add("blah.txt")
      r7z.is_valid_archive?("/home/leej/this_does_not_exist.zip").should eq false
    end
  end
end


