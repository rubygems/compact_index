require "compact_index/gem"
require "compact_index/gem_version"
require "compact_index/dependency"

require "compact_index/version"
require "compact_index/versions_file"
require "compact_index/ext/date"

module CompactIndex
  def self.names(gem_names)
    "---\n" << gem_names.join("\n") << "\n"
  end

  def self.versions(versions_file, gems = nil, args = {})
    versions_file.contents(gems, args)
  end

  def self.info(versions)
    versions.inject("---\n") do |output, version|
      output << version.to_line << "\n"
    end
  end

end
