# frozen_string_literal: true

module CompactIndex
  Dependency = Struct.new(:gem, :version, :platform, :checksum) do # rubocop:disable Lint/StructNewOverride
    def version_and_platform
      if platform.nil? || platform == "ruby"
        version
      else
        "#{version}-#{platform}"
      end
    end
  end
end
