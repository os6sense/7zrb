
require_relative '../lib/7zrb'

describe Ruby7z do
  # Brittle test - the test_files must exist
  let(:test_files) { ["/home/leej/Downloads/7zt/FILE1.MP4", "/home/leej/Downloads/7zt/FILE2.MP4"] }
  let(:test_file) { "/home/leej/Downloads/7zt/FILE1.MP4" }
  let(:target) { "/home/leej/RSTEST.zip"}
  let(:r7z) { Ruby7z.new }

  describe :initialize do
    it "takes a stringlike filename" do
      expect(Ruby7z.new(test_file)).not_to eq nil
     #expect{ Ruby7z.new(test_file).should_not eq nil
    end

    it "accepts zero parameters" do 
      expect(Ruby7z.new()).not_to eq nil
    end

    it "accepts an array of parameters" do 
      expect(Ruby7z.new(test_files)).not_to eq nil
    end
  end

  describe :add do
    it "accepts an array of filenames" do 
      r7z.add(test_files)
      test_files.each { |f| expect(r7z.filelist.include?(f)).to eq true }
    end

    it "accepts a single filename" do
      r7z.add(test_file)
      expect(r7z.filelist.include?(test_file)).to eq true 
    end
  end

  describe :compress do
    before(:each) { r7z.add(test_files) }

    it "returns true on success" do
      expect(r7z.compress(target)).to eq true
    end

    it "creates the target zip file" do
      r7z.compress(target)
      expect(File.exist?(target)).to eq true
    end

    it "removes the zip from this list of in progress files" do
      r7z.compress(target)
      expect(Ruby7z.in_progress.include?(target)).to eq false
    end

  end

  # Note , this test is pretty fragile since a small file might have
  # finished before the in_progress check
  describe :in_progress? do
    before(:each) { r7z.add(test_files) }

    it "returns true while creating a zip, false otherwise" do
      t = Thread.new { r7z.compress(target) }
      sleep 0.001 # small sleep to allow compression to start
      expect(r7z.in_progress?(target)).to eq true
      t.join
      expect(r7z.in_progress?(target)).to eq false
    end
  end

  describe :is_valid_archive? do
    
    before(:all) do 
      r7z = Ruby7z.new
      r7z.compress("/home/leej/RSTEST.zip")
      r7z.add(["/home/leej/Downloads/7zt/FILE1.MP4", "/home/leej/Downloads/7zt/FILE2.MP4"]) 
    end

    it "returns true if the archive is valid" do
      expect(r7z.is_valid_archive?(target)).to eq true
    end

    it "returns false if the archive does not exist" do
      expect(r7z.is_valid_archive?("/home/leej/this_does_not_exist.zip")).to eq false
    end

    it "returns false if a file in the filelist does not exist" do
      r7z.add("blah.txt")
      expect(r7z.is_valid_archive?("/home/leej/this_does_not_exist.zip")).to eq false
    end
  end
end


