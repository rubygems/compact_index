module CompactIndex
  GemVersion = Struct.new(:number, :platform, :checksum, :info_checksum,
                          :dependencies, :ruby_version, :rubygems_version) do
    def number_and_platform
      if platform.nil? || platform == 'ruby'
        number.dup
      else
        "#{number}-#{platform}"
      end
    end
  end
end
