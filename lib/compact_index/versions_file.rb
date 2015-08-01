require 'compact_index'

class CompactIndex::VersionsFile
  def initialize(file = nil)
    @path = file || "/versions.list"
  end

  def contents(gems=nil)
    out = File.read(@path)
    out << parse_gems(gems) if gems
    out
  end

  def updated_at
    if File.exists? @path
      DateTime.parse(File.mtime(@path).to_s)
    else
      Time.at(0)
    end
  end

  def update_with(gems)
    if File.exists?(@path) && !File.zero?(@path)
      update(gems)
    else
      create(gems)
    end
  end


  private


    def create(gems)
      content = "created_at: #{Time.now.iso8601}"
      content << "\n---\n"
      content << parse_gems_for_create(gems)

      File.open(@path, 'w') do |io|
        io.write content
      end
    end

    def update(gems)
      File.open(@path, 'a') do |io|
        io.write parse_gems(gems)
      end
    end

    def parse_gems_for_create(gems)
      fixed_format_gems = gems.map do |k,v|
        numbers = v.map { |x| x[:number] }
        { name: k, versions: numbers, checksum: v.first[:checksum] }
      end
      fixed_format_gems.sort! { |a,b| a[:name] <=> b[:name] }
      gem_lines(fixed_format_gems)
    end

    def parse_gems(gems)
      sorted_gems = format_by_created_time(gems)
      gem_lines(sorted_gems)
    end

    def format_by_created_time(gems)
      by_created_at = {}
      checksums = {}
      gems.each do |name, versions|
        versions.each do |v|
          by_created_at[v[:created_at]] ||= {}
          by_created_at[v[:created_at]][name] ||= []
          by_created_at[v[:created_at]][name] << number_and_platform(v[:number], v[:platform])
          checksums[v[:created_at]] ||= {}
          checksums[v[:created_at]] = v[:checksum]
        end
      end
      by_created_at.sort.map do |created_at,gems|
        gems.map do |name, versions|
          { name: name, versions: versions, checksum: checksums[created_at] }
        end
      end.flatten
    end

    def gem_lines(gems)
      gems.reduce("") do |concat, entry|
        versions = sort_versions(entry[:versions])
        concat << "#{entry[:name]} #{versions.join(',')} #{entry[:checksum]}\n"
      end
    end

    def sort_versions(versions)
      versions.sort_by { |v| Gem::Version.create(v) }
    end

    def number_and_platform(number, platform)
      if platform.nil? || platform == 'ruby'
        number
      else
        "#{number}-#{platform}"
      end
    end
end
