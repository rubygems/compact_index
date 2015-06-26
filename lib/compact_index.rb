require "compact_index/version"
require "compact_index/versions_file"
require "compact_index/gem_info"

module CompactIndex
  def self.names(conn)
    "---\n" + GemInfo.new(conn).names.join("\n") + "\n"
  end

  def self.versions(conn)
    VersionsFile.new(conn).with_new_gems
  end

  def self.info(conn, name)
    output = "---\n"
    name = [name] if name.kind_of? String
    GemInfo.new(conn).deps_for(name).each do |row|
      output << version_line(row) << "\n"
    end
    output
  end

  private
    def self.version_line(row)
      deps = row[:dependencies].map do |d|
        [d.first, d.last.gsub(/, /, "&")].join(":")
      end

      line = row[:number].to_s
      line << "-#{row[:platform]}" unless row[:platform] == "ruby"
      line << " " << deps.join(",") if deps.any?
      line
    end
end
