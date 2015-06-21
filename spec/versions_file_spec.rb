require 'sequel'
require 'tempfile'
require 'spec_helper'
require 'compact_index/versions_file'
require 'support/gem_builder'
require 'support/versions_file'

describe CompactIndex::VersionsFile do
  let(:db)       { $db }
  let(:builder)  { GemBuilder.new(db) }
  let(:versions_file) { CompactIndex::VersionsFile.new(db) }
  let (:yesterday) { DateTime.now - 86400 }
  let (:tomorrow) { DateTime.now + 86400 }
  let (:next_week) { DateTime.now + (7*86400) }
  let (:file_creation_time) { Time.now }

  before do
    a = builder.create_rubygem("a")
    b = builder.create_rubygem("b")
    builder.create_version(a, "a", "0.0.1", "ruby", { time: yesterday })
    builder.create_version(b, "b", "0.0.2", "ruby", { time: yesterday })
    builder.create_version(b, "b", "0.1.1", "java", { time: yesterday })
    builder.create_version(b, "b", "0.1.2", "ruby", { time: yesterday })
  end
  let (:file_contents) { "created_at: 2015-06-11T23:29:59-03:00\n---\na 0.0.1\nb 0.0.2,0.1.1-java,0.1.2" } 

  describe "#create"  do
    it "create the versions.list file with the gems on database" do
      file = Tempfile.new('versions.list')
      with_versions_file file.path do
        versions_file.create
        file.rewind
        expect(file.read).to match(/\d+\n---\na 0\.0\.1\nb 0\.0\.2,0\.1\.1-java,0\.1\.2/)
      end
    end
  end

  describe "#update" do
    before do
      b = builder.rubygem_id("b")
      c = builder.create_rubygem("c")
      builder.create_version(b, "b", "0.2.0", "rbx",{ time: tomorrow })
      builder.create_version(b, "b", "0.2.0", "ruby",{ time:  tomorrow })
      builder.create_version(c, "c", "1.0.0", "ruby",{ time:  tomorrow })
    end

    it "add new versions to the bottom of file" do
      file = Tempfile.new('versions.list')
      file.write file_contents
      file.rewind
      with_versions_file file.path do
        versions_file.update
        file.rewind
        expect(file.read).to eq(file_contents + "\nb 0.2.0\nb 0.2.0-rbx\nc 1.0.0")
      end
    end
  end

  describe "#with_new_gems" do
    context "is has nothing new" do
      before { allow_any_instance_of(File).to receive(:read).and_return("file_contents") }
      before { allow_any_instance_of(File).to receive(:mtime).and_return(file_creation_time) }

      it "return the same content from versions.list file" do
        file = Tempfile.new('versions.list')
        with_versions_file file.path do
          expect(versions_file.with_new_gems).to eq(versions_file.send(:content))
        end
      end
    end

    context "when has something new" do
      before { allow_any_instance_of(File).to receive(:read).and_return(file_contents) }
      before { allow_any_instance_of(File).to receive(:mtime).and_return(file_creation_time) }
      before do
        b = builder.rubygem_id("b")
        c = builder.create_rubygem("c")
        builder.create_version(b, "b", "0.2.0", "rbx", { time: tomorrow })
        builder.create_version(b, "b", "0.2.0", "ruby", { time: tomorrow })
        builder.create_version(c, "c", "1.0.0", "ruby", { time: tomorrow })
      end

      it "return the content from versions.list with new gems on bottom" do
        file = Tempfile.new('versions.list')
        with_versions_file file.path do
          expect(versions_file.with_new_gems).to eq(file_contents + "\nb 0.2.0\nb 0.2.0-rbx\nc 1.0.0")
        end
      end

      context "from different dates" do
        before do
          b = builder.rubygem_id("b")
          c = builder.rubygem_id("c")
          builder.create_version(b, "b", "0.2.2", "rbx", { time: next_week })
          builder.create_version(b, "b", "0.2.2", "ruby", { time:  next_week })
          builder.create_version(c, "c", "1.0.1", "ruby", { time:  next_week })
        end

        it "return the content from versions.list with new gems on bottom" do
          first_changes = "\nb 0.2.0\nb 0.2.0-rbx\nc 1.0.0"
          second_changes = "\nb 0.2.2\nb 0.2.2-rbx\nc 1.0.1"
          file = Tempfile.new('versions.list')
          with_versions_file file.path do
            expect(versions_file.with_new_gems).to eq(file_contents + first_changes + second_changes )
          end
        end
      end
    end
  end
end
