require 'tempfile'
require 'spec_helper'
require 'compact_index/versions_file'
require 'support/versions'
require 'support/versions_file'

describe CompactIndex::VersionsFile do
  before :all do
    @file_contents = "gem1 1.1,1.2\ngem2 2.1,2.1-jruby\n"
    @file = Tempfile.new('versions.list')
    @file.write @file_contents
    @file.rewind
  end

  after :all do
    @file.unlink
  end

  let(:versions_file) do
    CompactIndex::VersionsFile.new(@file.path)
  end

  let(:gem_time) { Time.now }

  context "using the file" do
    let(:file) { Tempfile.new("create_versions.list") }
    let(:gems) do
        [
          CompactIndex::Gem.new("gem5", [ build_version(:number => "1.0.1") ]),
          CompactIndex::Gem.new("gem2", [
            build_version(:number => "1.0.1"),
            build_version(:number => "1.0.2", :platform => 'arch')
          ])
        ]
    end
    let(:versions_file) { versions_file = CompactIndex::VersionsFile.new(file.path) }


    describe "#update_with" do
      describe "when file do not exist"  do
        it "write the gems" do
          expected_file_output = /created_at: .*?\n---\ngem2 1.0.1,1.0.2-arch abc123\ngem5 1.0.1 abc123\n/
          versions_file.update_with(gems)
          expect(file.open.read).to match(expected_file_output)
        end

        it "add the date on top" do
          date_regexp = /^created_at: (.*?)\n/
          versions_file.update_with(gems)
          expect(
            file.open.read.match(date_regexp)[0]
          ).to match(
            /(\d{4})-(\d{2})-(\d{2})T(\d{2})\:(\d{2})\:(\d{2})[+-](\d{2})\:(\d{2})/
          )
        end

        it "order gems by name" do
          file = Tempfile.new('versions-sort')
          versions_file = CompactIndex::VersionsFile.new(file)
          gems = [
            CompactIndex::Gem.new("gem_b", [ build_version] ),
            CompactIndex::Gem.new("gem_a", [ build_version] )
          ]
          versions_file.update_with(gems)
          expect(file.open.read).to match(/gem_a 1.0 abc123\ngem_b 1.0/)
        end

        it "order versions by number" do
          file = Tempfile.new('versions-sort')
          versions_file = CompactIndex::VersionsFile.new(file)
          gems = [
            CompactIndex::Gem.new('test', [
              build_version(:number => "2.2"),
              build_version(:number => "1.1.1-b"),
              build_version(:number => "1.1.1-a"),
              build_version(:number => "1.1.1"),
              build_version(:number => "2.1.2")
            ])
          ]
          versions_file.update_with(gems)
          expect(file.open.read).to match(/test 1.1.1-a,1.1.1-b,1.1.1,2.1.2,2.2 abc123/)
        end
      end

      describe "when file exists" do
        before(:each) { versions_file.send('create',gems) }

        it "add a gem" do
          gems = [CompactIndex::Gem.new('new-gem', [build_version])]
          expected_output = "---\ngem2 1.0.1,1.0.2-arch abc123\ngem5 1.0.1 abc123\nnew-gem 1.0 abc123\n"
          versions_file.update_with(gems)
          expect(file.open.read).to match(expected_output)
        end

        it "add again even if already listed" do
          gems = [ CompactIndex::Gem.new('gem5', [ build_version(:number => "3.0") ]) ]
          expected_output = "---\ngem2 1.0.1,1.0.2-arch abc123\ngem5 1.0.1 abc123\ngem5 3.0 abc123\n"
          versions_file.update_with(gems)
          expect(file.open.read).to match(expected_output)
        end
      end
    end
  end

  describe "#updated_at" do
    it "is a date time" do
      expect(versions_file.updated_at).to be_kind_of(DateTime)
    end
    it "uses File#mtime" do
      expect(File).to receive('mtime') { DateTime.now }
      versions_file.updated_at
    end
  end

  describe "#contents" do
    it "return the file" do
      expect(versions_file.contents).to eq(@file_contents)
    end

    it "receive extra gems" do
      extra_gems = [
        CompactIndex::Gem.new("gem3", [
          build_version(:number => "1.0.1"),
          build_version(:number => "1.0.2", :platform => 'arch')
        ])
      ]
      expect(
        versions_file.contents(extra_gems)
      ).to eq(
        @file_contents + "gem3 1.0.1,1.0.2-arch abc123\n"
      )
    end

    it "has checksum" do
      gems = [
        CompactIndex::Gem.new('test', [
          build_version(:checksum => 'testsum', :number => '1.0')
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
        CompactIndex::Gem.new('test', [
          build_version(:number => '1.0', :platform => 'jruby')
        ])
      ]
      expect(
        versions_file.contents(gems)
      ).to match(
        /test 1.0-jruby abc123/
      )
    end

    describe "with calculate_info_checksums flag" do
      context "passing dependencies as parameters" do
        let(:gems) do
          [
            CompactIndex::Gem.new('test', [
                build_version(:number => '1.0', :platform => 'ruby', :dependencies => [
                  CompactIndex::Dependency.new('foo', '=1.0.1', 'ruby', 'abc123')
                ])
            ])
          ]
        end
        it "calculates the info_checksums on the fly" do
          expect(
            versions_file.contents(gems, :calculate_checksums => true)
          ).to match(
            /test 1.0 a6beccb34e26aa9e082bda0d8fa4ee77/
          )
        end
      end
    end

    pending "conflicting checksums"
  end
end
