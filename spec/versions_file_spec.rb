require 'tempfile'
require 'spec_helper'
require 'compact_index/versions_file'
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
        {
          "gem5" => [
            { checksum: 'abc123', created_at: gem_time, number: "1.0.1" }
          ],
          "gem2" => [
            { checksum: 'abc123', created_at: gem_time, number: "1.0.1" },
            { checksum: 'abc123', created_at: gem_time, number: "1.0.2-arch" }
          ]
        }
    end
    let(:versions_file) { versions_file = CompactIndex::VersionsFile.new(file.path) }

    before(:each) do
      versions_file.create(gems)
    end

    describe "#create"  do
      it "write the gems" do
        expected_file_output = /created_at: .*?\n---\ngem2 1.0.1,1.0.2-arch abc123\ngem5 1.0.1 abc123\n/
        expect(file.open.read).to match(expected_file_output)
      end

      it "add the date on top" do
        date_regexp = /^created_at: (.*?)\n/
        expect(
          file.open.read.match(date_regexp)[0]
        ).to match (
          /(\d{4})-(\d{2})-(\d{2})T(\d{2})\:(\d{2})\:(\d{2})[+-](\d{2})\:(\d{2})/
        )
      end

      it "order gems by name" do
        file = Tempfile.new('versions-sort')
        versions_file = CompactIndex::VersionsFile.new(file)
        file.close
        gems = {
          "gem_b" => [ { checksum: 'abc123', created_at: gem_time, number: "1.0" } ],
          "gem_a" => [ { checksum: 'abc123', created_at: gem_time, number: "1.0" } ]
        }
        versions_file.create(gems)
        expect(file.open.read).to match(/gem_a 1.0 abc123\ngem_b 1.0/)
      end

      it "order versions by number" do
        file = Tempfile.new('versions-sort')
        versions_file = CompactIndex::VersionsFile.new(file)
        file.close
        gems = { 'test' => [
          { checksum: 'abc123', created_at: gem_time, number: "2.2" },
          { checksum: 'abc123', created_at: gem_time+1, number: "1.1.1-b" },
          { checksum: 'abc123', created_at: gem_time+2, number: "1.1.1-a" },
          { checksum: 'abc123', created_at: gem_time+3, number: "1.1.1" },
          { checksum: 'abc123', created_at: gem_time+4, number: "2.1.2" }
        ]}
        versions_file.create(gems)
        expect(file.open.read).to match(/test 1.1.1-a,1.1.1-b,1.1.1,2.1.2,2.2 abc123/)
      end
    end

    describe "#update" do
      it "add a gem" do
        gems = { 'new-gem' => [{ checksum: 'abc123', created_at: gem_time, number: "1.0" }]}
        expected_output = "---\ngem2 1.0.1,1.0.2-arch abc123\ngem5 1.0.1 abc123\nnew-gem 1.0 abc123\n"
        versions_file.update(gems)
        expect(file.open.read).to match(expected_output)
      end

      it "add again even if already listed" do
        gems = { 'gem5' => [{ checksum: 'abc123', created_at: gem_time, number: "3.0" }]}
        expected_output = "---\ngem2 1.0.1,1.0.2-arch abc123\ngem5 1.0.1 abc123\ngem5 3.0 abc123\n"
        versions_file.update(gems)
        expect(file.open.read).to match(expected_output)
      end

      it "order versions by number" do
        gems = { 'test' => [
          { checksum: 'abc123', created_at: gem_time, number: "2.2" },
          { checksum: 'abc123', created_at: gem_time, number: "1.1.1-b" },
          { checksum: 'abc123', created_at: gem_time, number: "1.1.1-a" },
          { checksum: 'abc123', created_at: gem_time, number: "1.1.1" },
          { checksum: 'abc123', created_at: gem_time, number: "2.1.2" }
        ]}
        versions_file.update(gems)
        expect(file.open.read).to match(/test 1.1.1-a,1.1.1-b,1.1.1,2.1.2,2.2 abc123/)
      end

      it "order by creation time" do
        gems = { 'test' => [
          { checksum: 'abc123', created_at: gem_time, number: "2.2" },
          { checksum: 'abc123', created_at: gem_time + 1, number: "2.3" },
          { checksum: 'abc123', created_at: gem_time + 1, number: "2.4" },
          { checksum: 'abc123', created_at: gem_time + 2, number: "2.5" }
        ]}
        versions_file.update(gems)
        expect(file.open.read).to match(/test 2.2 abc123\ntest 2.3,2.4 abc123\ntest 2.5 abc123\n/)
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
      extra_gems = {"gem3" => [
        { checksum: 'abc123', created_at: gem_time, number: "1.0.1" },
        { checksum: 'abc123', created_at: gem_time, number: "1.0.2-arch" }
      ]}
      expect(
        versions_file.contents(extra_gems)
      ).to eq(
        @file_contents + "gem3 1.0.1,1.0.2-arch abc123\n"
      )
    end

    it "order versions by number" do
      gems = { 'test' => [
        { checksum: 'abc123', created_at: gem_time, number: "2.2" },
        { checksum: 'abc123', created_at: gem_time, number: "1.1.1-b" },
        { checksum: 'abc123', created_at: gem_time, number: "1.1.1-a" },
        { checksum: 'abc123', created_at: gem_time, number: "1.1.1" },
        { checksum: 'abc123', created_at: gem_time, number: "2.1.2" }
      ]}
      expect(
        versions_file.contents(gems)
      ).to match(
        /test 1.1.1-a,1.1.1-b,1.1.1,2.1.2,2.2 abc123/
      )
    end

    it "order by creation time" do
      gems = { 'test' => [
        { checksum: 'abc123', created_at: gem_time, number: "2.2" },
        { checksum: 'abc123', created_at: gem_time + 1, number: "2.3" },
        { checksum: 'abc123', created_at: gem_time + 1, number: "2.4" },
        { checksum: 'abc123', created_at: gem_time + 2, number: "2.5" }
      ]}
      expect(
        versions_file.contents(gems)
      ).to match(
        /test 2.2 abc123\ntest 2.3,2.4 abc123\ntest 2.5 abc123\n/
      )
    end

    it "has checksum" do
      gems = { 'test' => [
        { checksum: 'abc123', created_at: gem_time, number: '1.0' }
      ]}
      expect(
        versions_file.contents(gems)
      ).to match(
        /test 1.0 abc123/
      )
    end

    pending "conflicting checksums"

  end
end
