# frozen_string_literal: true

require "tempfile"
require "spec_helper"
require "compact_index/versions_file"
require "support/versions"
require "support/versions_file"

describe CompactIndex::VersionsFile do
  before :all do
    @file_contents = "gem1 1.1,1.2\ngem2 2.1,2.1-jruby\n"
    @file = Tempfile.new("versions.list")
    @file.write @file_contents
    @file.rewind
  end

  after :all do
    @file.unlink
  end

  let(:versions_file) do
    CompactIndex::VersionsFile.new(@file.path)
  end

  let(:now) { Time.now }

  before do
    allow(Time).to receive(:now).and_return(now)
  end

  context "using the file" do
    let(:file) { Tempfile.new("create_versions.list") }
    let(:gems) do
      [
        CompactIndex::Gem.new("gem5", [build_version(:name => "gem5", :number => "1.0.1")]),
        CompactIndex::Gem.new("gem2", [
                                build_version(:name => "gem2", :number => "1.0.1"),
                                build_version(:name => "gem2", :number => "1.0.2", :platform => "arch")
                              ])
      ]
    end
    let(:versions_file) { versions_file = CompactIndex::VersionsFile.new(file.path) }

    # rubocop:disable Style/IndentHeredoc
    describe "#create" do
      it "writes one line per gem" do
        expected_file_output = <<-EOS
created_at: #{now.iso8601}
---
gem2 1.0.1,1.0.2-arch info+gem2+1.0.2
gem5 1.0.1 info+gem5+1.0.1
        EOS
        versions_file.create(gems)
        expect(file.open.read).to eq(expected_file_output)
      end

      it "adds the date on top" do
        versions_file.create(gems)
        expect(file.open.read).to start_with "created_at: #{now.iso8601}\n"
      end

      it "orders gems by name" do
        file = Tempfile.new("versions-sort")
        versions_file = CompactIndex::VersionsFile.new(file.path)
        gems = [
          CompactIndex::Gem.new("gem_b", [build_version]),
          CompactIndex::Gem.new("gem_a", [build_version])
        ]
        versions_file.create(gems)
        expect(file.open.read).to eq(<<-EOS)
created_at: #{now.iso8601}
---
gem_a 1.0 info+test_gem+1.0
gem_b 1.0 info+test_gem+1.0
      EOS
      end

      it "uses the given version order" do
        file = Tempfile.new("versions-sort")
        versions_file = CompactIndex::VersionsFile.new(file.path)
        gems = [
          CompactIndex::Gem.new("test",
            [
              build_version(:number => "1.3.0"),
              build_version(:number => "2.2"),
              build_version(:number => "1.1.1"),
              build_version(:number => "1.1.1"),
              build_version(:number => "2.1.2")
            ])
        ]
        versions_file.create(gems)
        expect(file.open.read).to include("test 1.3.0,2.2,1.1.1,1.1.1,2.1.2 info+test_gem+2.1.2")
      end
    end
  end

  describe "#updated_at" do
    it "is epoch start when file does not exist" do
      expect(CompactIndex::VersionsFile.new("/tmp/doesntexist").updated_at).to eq(Time.at(0).to_datetime)
    end

    it "is epoch when created_at header does not exist" do
      expect(versions_file.updated_at).to eq(Time.at(0).to_datetime)
    end

    it "is the created_at time when the header exists" do
      Tempfile.new("created_at_versions") do |tmp|
        tmp.write("created_at: 2015-08-23T17:22:53-07:00\n---\ngem2 1.0.1\n")
        file = CompactIndex::VersionsFile.new(tmp.path).updated_at
        expect(file.updated_at).to eq(DateTime.parse("2015-08-23T17:22:53-07:00"))
      end
    end
  end

  describe "#contents" do
    it "raises when there are unknown options" do
      expect { versions_file.contents(nil, :foo => :bar) }.to raise_error(ArgumentError)
    end

    it "return the file" do
      expect(versions_file.contents).to eq(@file_contents)
    end

    it "includes extra gems if given" do
      extra_gems = [
        CompactIndex::Gem.new("gem3", [
                                build_version(:name => "gem3", :number => "1.0.1"),
                                build_version(:name => "gem3", :number => "1.0.2", :platform => "arch")
                              ])
      ]
      expect(
        versions_file.contents(extra_gems)
      ).to eq(
        @file_contents + "gem3 1.0.1,1.0.2-arch info+gem3+1.0.2\n"
      )
    end

    it "has info_checksum" do
      gems = [
        CompactIndex::Gem.new("test", [
                                build_version(:info_checksum => "testsum", :number => "1.0")
                              ])
      ]
      expect(
        versions_file.contents(gems)
      ).to match(
        /test 1.0 testsum/
      )
    end

    it "has the platform" do
      gems = [
        CompactIndex::Gem.new("test", [
                                build_version(:name => "test", :number => "1.0", :platform => "jruby")
                              ])
      ]
      expect(
        versions_file.contents(gems)
      ).to include(
        "test 1.0-jruby info+test+1.0"
      )
    end

    describe "with calculate_info_checksums flag" do
      let(:gems) do
        [
          CompactIndex::Gem.new("test",
            [
              build_version(:number => "1.0", :platform => "ruby", :dependencies =>
                [
                  CompactIndex::Dependency.new("foo", "=1.0.1", "ruby", "abc123")
                ])
            ])
        ]
      end

      it "calculates the info_checksums on the fly" do
        expect(
          versions_file.contents(gems, :calculate_info_checksums => true)
        ).to match(
          /test 1.0 b1c5ae823c07dba64028e4b37a2a2ba7/
        )
      end
    end

    pending "conflicting checksums"
  end
end
