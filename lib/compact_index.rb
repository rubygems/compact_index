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

      after_pipe = []
      after_pipe << "checksum:#{version[:checksum]}"
      after_pipe << "ruby:#{version[:ruby_version]}" if version[:ruby_version]
      after_pipe << "rubygems:#{version[:rubygems_version]}" if version[:rubygems_version]
      line << after_pipe.join(",")
      
      line
    end
end
