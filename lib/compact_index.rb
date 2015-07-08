require "compact_index/version"
require "compact_index/versions_file"
require "compact_index/gem_info"

module CompactIndex
  def self.names(gem_names)
    "---\n" + gem_names.join("\n") + "\n"
  end

  def self.versions(versions_file, gems)
    versions_file.contents(gems)
  end

  def self.info(params)
    output = "---\n"
    params.each do |version|
      output << version_line(version) << "\n"
    end
    output
  end

  private
    def self.version_line(version)
      if version[:dependencies]
        version[:dependencies].sort! { |a,b| a[:gem] <=> b[:gem] }
        deps = version[:dependencies].map do |d|
          [
             d[:gem],
             d[:version].gsub(/, /, "&")
          ].join(':')
        end
      else
        deps = []
      end

      line = version[:number]
      line << " " << deps.join(",") if deps.any?
      line << "|"
      line << "checksum:#{version[:checksum]}"
      line
    end
end
