def build_version(args = {})
  {
    checksum: args[:checksum] || 'abc123',
    created_at: args[:created_at] || Time.now,
    number: args[:number] || '1.0'
  }
end
