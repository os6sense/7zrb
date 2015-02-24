# 
# Ruby7z is a simple wrapper around p7zip sine rubyzip was broken when I came to
# test it out. As a requirement p7zip-full must be installed.

# Example
# if __FILE__ == $0
#   filelist = "/home/leej/Downloads/7zt/hs1.mkv"
#   r7z = Ruby7z.new(filelist)

#   r7z2 = Ruby7z.new()
#   r7z.add ["/home/leej/Downloads/7zt/hs2.mkv", "/home/leej/Downloads/7zt/hs2.mkv"]

#   target = "/home/leej/TEST.zip"
#   puts r7z.in_progress?  target
#   r7z.compress target
#   puts r7z.in_progress? target

#   puts r7z.is_valid_archive? target
# end
#
# TODO: Validate 7zr exists
class Ruby7z
  attr_reader :filelist

  class << self 
     attr_accessor :in_progress, :executable 
  end

  @executable = '/usr/bin/7z'
  @in_progress = []

  # Description::
  # Change the location of the 7z archive executable
  def set_7z(full_path_and_filename)
    Ruby7z.executable = full_path_and_filename
  end

  # Description::
  # Initialise, optionally passing a file or list of files to add to the
  # archive
  def initialize(files = nil)
    @filelist = []
    add(files) if files
  end

  # Description::
  # Add a file to the list of files to be compressed
  #
  # Params::
  # +files+ -- array of filenames, or filename, to be added
  def add(files)
    files = *files
    files.each { | f | @filelist << f unless @filelist.include? f }
  end

  # Description::
  # returns true if the filname passed is currently being created
  #
  # +target+ - filename of archive being created.
  def in_progress?(target)
    Ruby7z.in_progress.include? target
  end

  # Description::
  # Test a zip archive. Returns false IF:
  #   - The file does not exist
  #   - Any of the files passed to +add+ are not present in the target zip.
  #   - The 7z test of the archive integrety fails.
  # Params::
  # +target+ -- zip file to fest
  def is_valid_archive?(target)
    return false if Ruby7z.in_progress.include? target
    return false unless File.exist? target

    results = `#{Ruby7z.executable } t #{target}`
    filelist.each do | f |
      return false unless results.include? "Testing     #{File.basename(f)}"
    end

    return true if results.include? "Everything is Ok"
    false
  end

  def extract(zipfile, full_path = false)
  end

  def list(zipfile)
  end

  def delete(filename, zipfile)
  end

  # Description::
  # Start the creation of the zip file.
  #
  # Returns::
  # true on success, false otherwise
  def compress(target)
    return false if Ruby7z.in_progress.include?(target)
    return false if @filelist.size == 0

    Ruby7z.in_progress << target

    `#{Ruby7z.executable } -tzip -mx=0 a #{target} #{@filelist.join(" ")}`
    Ruby7z.in_progress.delete target

    return true
  rescue Exception, e
    return false
  ensure
    Ruby7z.finished target
  end

  def self.finished(target)
    in_progress.delete target
  end

end

