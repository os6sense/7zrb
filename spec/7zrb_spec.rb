require_relative '../lib/7zrb'

describe Ruby7z do
  let(:zip_file) { '/tmp/spectest.zip' }

  before(:each) do
    %w(/tmp/1.txt /tmp/2.txt /tmp/3.txt /tmp/4.txt).each do |filename|
      File.open("#{filename}", 'w') { |file| file.write("#{filename}") }
    end

    File.delete zip_file if File.exist? zip_file
  end

  let(:r7z) { Ruby7z.new(zip_file) }
  let(:test_files) { %w(/tmp/1.txt /tmp/2.txt /tmp/3.txt /tmp/4.txt) }
  let(:single_file) { '/tmp/1.txt' }

  describe :initialize do
    it 'takes a filename' do
      expect(Ruby7z.new(zip_file)).not_to eq nil
    end

    it 'accepts an optional array of filenames as the 2nd parameter' do
      expect(Ruby7z.new(zip_file, test_files)).not_to eq nil
    end
  end

  describe :add do
    it 'accepts an array of filenames' do
      r7z.add(test_files)
      test_files.each { |f| expect(r7z.filelist.include?(f)).to eq true }
    end

    it 'accepts a single filename' do
      r7z.add(single_file)
      expect(r7z.filelist.include?('/tmp/1.txt')).to eq true
    end

    it 'fails with an exception if any file does not exist' do
      expect { r7z.add('file_does_not_exist.txt') }.to raise_error
    end
  end

  describe :compress do
    before(:each) { r7z.add(test_files) }

    it 'returns true on success' do
      expect(r7z.compress).to eq true
    end

    it 'returns false on failure' do
      zip_file = '/tmp/ro_spectest.zip'
      `touch #{zip_file} && chmod -r #{zip_file}`

      r7z = Ruby7z.new(zip_file)
      r7z.add(test_files)

      expect(r7z.compress).to eq false
    end

    it 'creates the target zip file' do
      r7z.compress
      expect(File.exist?(zip_file)).to eq true
    end
  end

  describe :'Ruby7z.executable' do
    it 'is the path to the 7z binary, /usr/bin/7z by default' do
      expect(Ruby7z.executable).to eq '/usr/bin/7z'
    end

    it 'can be changed' do
      Ruby7z.executable = '/usr/local/bin/7z'
      expect(Ruby7z.executable).to eq '/usr/local/bin/7z'
      Ruby7z.executable = '/usr/bin/7z'
    end
  end

  describe :valid_archive? do
    it 'returns true if the archive is valid' do
      r7z.add(test_files)
      r7z.compress
      expect(r7z.valid_archive?).to eq true
    end

    it 'returns false if the archive does not exist' do
      expect(r7z.valid_archive?).to eq false
    end
  end

  describe :extract do
    it 'extracts the files from the zip into the specifed directory' do
      r7z.add(test_files)
      r7z.compress
      r7z.extract('/tmp/test_extract')
      expect(File.exist?('/tmp/test_extract/1.txt')).to eq true
    end
  end

  describe :list do
    it 'returns an array listing the files in the zip' do
      r7z.add(test_files)
      r7z.compress
      expect(r7z.list).to eq %w(1.txt 2.txt 3.txt 4.txt)
    end
  end

  describe :delete do
    it 'removes a file from a zip' do
      r7z.add(test_files)
      r7z.compress
      r7z.delete('1.txt')
      expect(r7z.list).to eq %w(2.txt 3.txt 4.txt)
    end
  end
end
