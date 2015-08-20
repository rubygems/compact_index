module CompactIndex
  GemVersion = Struct.new(:number, :platform, :checksum, :info_checksum, :dependencies, :ruby_version, :rubygems_version)
end
