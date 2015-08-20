def build_version(args = {})
    name = args[:name] || 'test_gem'
    number = args[:number] || '1.0'
    platform = args[:platform] || nil
    checksum = args[:checksum] || 'abc123'
    info_checksum = args[:info_checksum] || 'abc123'
    dependencies = args[:dependencies] || nil
    ruby_version = args[:ruby_version] || nil
    rubygems_version = args[:rubygems_version] || nil
    CompactIndex::GemVersion.new(number, platform, checksum, nil, dependencies, ruby_version, rubygems_version)
end
