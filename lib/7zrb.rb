class Ruby7z
  attr_accessor :filelist

  class << self
     attr_accessor :executable
  end

  @executable = '/usr/bin/7z'

  # Description::
  # Initialise, optionally passing a file or list of files to add to the
  # archive
  def initialize(zip_file, files = nil)
    @zip_file = zip_file
    @filelist = []

    add(files) if files
  end

  # Description::
  # Add a file to the list of files to be compressed
  #
  # Params::
  # +files+ -- array of filenames, or filename, to be added
  #
  # Returns::
  # false unless all the files exist, true otherwise. If *any* of the files
  # do not exist them *none* of the files are added for zipping.
  def add(files)
    files = *files
    files.each do |f|
      fail "File #{f} does not exist and hence cannot be added to zip" \
        unless File.exist? f
      @filelist << f unless @filelist.include? f
    end
  end

  # Description::
  # Creates a new zip file if it doesn't exist.  Any files that have been added
  # via #add will be compressed into the zipfile.
  #
  # Returns::
  # true on success, false otherwise
  def compress
    return false if @filelist.size == 0
    result = `#{self.class.executable} -tzip -mx=0 a #{@zip_file} \
                #{@filelist.join(' ')}`
    return true if result.include? 'Everything is Ok'

    return false
  end

  # ==== Description
  # Deletes the given file fromt the zip archive
  def delete(file)
    self.class.delete(@zip_file, file)
  end

  # ==== Description
  # return an array of the files within the zipfile
  def list
    self.class.list(@zip_file)
  end

  # ==== Description::
  # Test the zip archive. Returns false IF:
  #   - The file does not exist
  #   - Any of the files passed to +add+ are not present in the target zip.
  #   - The 7z test of the archive integrety fails.
  def valid_archive?
    self.class.valid_archive?(@zip_file)
  end

  def self.valid_archive?(zip_file)
    return false unless File.exist? zip_file
    return true if `#{executable} t #{zip_file}`.include? 'Everything is Ok'

    false
  end

  # ==== Description
  # Extract files in the zip to the path specified via outdir
  # ==== Params
  # +out_dir+ -- name of the file to list files of.
  # +use_full_path+ -- if true extracts with directory paths
  def extract(out_dir, use_full_paths = false)
    self.class.extract(@zip_file, out_dir, use_full_paths)
  end

  def self.extract(zip_file, out_dir, use_full_paths)
    `#{Ruby7z.executable} #{use_full_paths ? 'x' : 'e'} \
      -o#{out_dir} -y #{zip_file}`
  end

  # ==== Description
  # return an array of the files within the zipfile
  #
  # ==== Params
  # +zip_file+ -- name of the file to list files of.
  def self.list(zip_file)
    return [] unless File.exist? zip_file

    (`#{executable} l #{zip_file}`).split("\n")[13..-3].map { |r| r.split.last }
  end

  # ==== Description
  # delete a file from a zip
  #
  # ==== Params
  # zip_file - name of the file to list files of.
  # file - name of the file to delete
  def self.delete(zip_file, file)
    `#{executable} d #{zip_file} #{file}`
  end
end
