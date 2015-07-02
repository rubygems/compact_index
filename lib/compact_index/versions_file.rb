require 'compact_index'

class CompactIndex::VersionsFile
  def initialize(path = ".")
    @path = "#{path}/versions.list"
  end

  def create
    content = "created_at: #{Time.now.iso8601}"
    content += "\n---\n"
    #content += gems_for_new_file
    content += "\n"

    File.open(@path, 'w') do |io|
      io.write content
    end
  end

  def update
  end

  def get(gems=nil)
  end

  private
    def content
      File.open(@path).read
    end

    def created_at
      DateTime.parse(File.mtime(@path).to_s)
    end
end
