require 'compact_index'

class CompactIndex::VersionsFile
  def initialize(file = nil)
    @path = file || "/versions.list"
  end

  def create(gems)
    content = "created_at: #{Time.now.iso8601}"
    content += "\n---\n"
    content += parse_gems(gems)

    File.open(@path, 'w') do |io|
      io.write content
    end
  end

  def update(gems)
    File.open(@path, 'a') do |io|
      io.write parse_gems(gems)
    end
  end

  def contents(gems=nil)
    out = File.open(@path).read
    out += parse_gems(gems) if gems
    out
  end

  def updated_at
    DateTime.parse(File.mtime(@path).to_s)
  end


  private

    def parse_gems(gems)
      gems.reduce("") do |concat, entry|
        versions = sort_versions(entry[:versions])
        concat + "#{entry[:name]} #{versions.join(',')}\n"
      end
    end

    def sort_versions(versions)
      versions.sort do |a,b|
        gem_comp = Gem::Version.new(a) <=> Gem::Version.new(b)
      end
    end
end
