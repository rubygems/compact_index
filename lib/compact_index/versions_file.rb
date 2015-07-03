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
      sorted_gems = format_by_created_time(gems)
      gem_lines(sorted_gems)
    end

    def format_by_created_time(gems)
      by_created_at = {}
      gems.each do |gem|
        gem[:versions].each do |v|
          by_created_at[v[:created_at]] ||= {}
          by_created_at[v[:created_at]][gem[:name]] ||= []
          by_created_at[v[:created_at]][gem[:name]] << v[:number]
        end
      end
      by_created_at.sort.map do |_,gems|
        gems.map do |name, versions|
          { name: name, versions: versions }
        end
      end.flatten
    end

    def gem_lines(gems)
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
