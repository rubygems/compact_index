require "compact_index/gem"
require "compact_index/gem_version"
require "compact_index/dependency"

require "compact_index/version"
require "compact_index/versions_file"

module CompactIndex
  def self.names(gem_names)
    "---\n" << gem_names.join("\n") << "\n"
  end

  def self.versions(versions_file, gems, args = {})
    versions_file.contents(gems, args)
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
        version[:dependencies]
        deps = version[:dependencies].map do |d|
          [
             d[:gem],
             number_and_platform(d[:version],d[:platform]).gsub(/, /, "&")
          ].join(':')
        end
      else
        deps = []
      end

      line = number_and_platform(version[:number], version[:platform])
      line << " "
      line << deps.join(",")
      line << "|"

      line << "checksum:#{version[:checksum]}"
      line << ",ruby:#{version[:ruby_version]}" if version[:ruby_version]
      line << ",rubygems:#{version[:rubygems_version]}" if version[:rubygems_version]

      line
    end

    def self.number_and_platform(number, platform)
      if platform.nil? || platform == 'ruby'
        number.dup
      else
        "#{number}-#{platform}"
      end
    end
end
