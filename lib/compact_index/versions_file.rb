# frozen_string_literal: true

require "time"
require "date"
require "digest"

module CompactIndex
  class VersionsFile
    def initialize(file = nil, only_info_checksums: false)
      @path = file || "/versions.list"
      @only_info_checksums = only_info_checksums
    end

    def contents(gems = nil, calculate_info_checksums: false)
      gems = calculate_info_checksums(gems) if calculate_info_checksums

      File.read(@path).tap do |out|
        out << gem_lines(gems) if gems
      end
    end

    def updated_at
      created_at_header(@path) || Time.at(0).to_datetime
    end

    def create(gems, timestamp = Time.now.iso8601)
      gems.sort!

      File.open(@path, "w") do |io|
        io.write "created_at: #{timestamp}\n---\n"
        io.write gem_lines(gems)
      end
    end

  private

    def gem_lines(gems)
      gems.reduce(+"") do |lines, gem|
        lines << gem.name
        unless @only_info_checksums
          version_numbers = gem.versions.map(&:number_and_platform).join(",")
          lines << " " << version_numbers
        end
        lines << " #{gem.versions.last.info_checksum}\n"
      end
    end

    def calculate_info_checksums(gems)
      gems.each do |gem|
        info_checksum = Digest::MD5.hexdigest(CompactIndex.info(gem[:versions]))
        gem[:versions].last[:info_checksum] = info_checksum
      end
    end

    def created_at_header(path)
      return unless File.exist? path

      File.open(path) do |file|
        file.each_line do |line|
          line.match(/created_at: (.*)\n|---\n/) do |match|
            return match[1] && DateTime.parse(match[1])
          end
        end
      end

      nil
    end
  end
end
