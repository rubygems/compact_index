def build_version(args = {})
  {
    name: args[:name] || 'test_gem',
    checksum: args[:checksum] || 'abc123',
    created_at: args[:created_at] || Time.now,
    number: args[:number] || '1.0',
    platform: args[:platform] || nil
  }
end
