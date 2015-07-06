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
      output << version_line(version[:number], version[:dependencies]) << "\n"
    end
    output
  end

  private
    def self.version_line(version, dependencies = nil)
      if dependencies
        dependencies.sort! { |a,b| a[:gem] <=> b[:gem] }
        deps = dependencies.map do |d|
          [
             d[:gem],
             d[:version].gsub(/, /, "&")
          ].join(':')
        end
      else
        deps = []
      end

      line = version
      line << " " << deps.join(",") if deps.any?
      line
    end
end
