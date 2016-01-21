require "tempfile"
require "spec_helper"
require "support/versions"

describe CompactIndex do
  it "has a version number" do
    expect(CompactIndex::VERSION).not_to be nil
  end

  describe ".names" do
    context "when receive one gem name" do
      let(:gem_names) { ["gem"] }
      it "returns the gem list" do
        expect(CompactIndex.names(gem_names)).to eq "---\ngem\n"
      end
    end
    context "when receive gem names" do
      let(:gem_names) { %w(gem-1 gem_2) }
      it "returns the gem list" do
        expect(CompactIndex.names(gem_names)).to eq "---\ngem-1\ngem_2\n"
      end
    end
  end

  describe ".versions" do
    it "delegates to VersionsFile#content" do
      file = Tempfile.new("versions-endpoint")
      versions_file = CompactIndex::VersionsFile.new(file.path)
      gems = [CompactIndex::Gem.new("test", [build_version])]
      expect(
        CompactIndex.versions(versions_file, gems)
      ).to eq(
        versions_file.contents(gems)
      )
    end
  end

  describe ".info" do
    it "without dependencies" do
      param = [ build_version(:number => "1.0.1") ]
      expect(CompactIndex.info(param)).to eq("---\n1.0.1 |checksum:sum+test_gem+1.0.1\n")
    end

    it "multiple versions" do
      today = Time.now
      yesterday = Time.at(Time.now.to_i - 86400)
      param = [
        build_version(:number => "1.0.1", :checksum => "abc1"),
        build_version(:number => "1.0.2", :checksum => "abc2")
      ]
      expect(CompactIndex.info(param)).to eq("---\n1.0.1 |checksum:abc1\n1.0.2 |checksum:abc2\n")
    end

    it "one dependency" do
      param = [ build_version(:number => "1.0.1", :dependencies => [
        CompactIndex::Dependency.new("foo", "=1.0.1", "ruby", "abc123")
      ])]
      expect(CompactIndex.info(param)).to eq("---\n1.0.1 foo:=1.0.1|checksum:sum+test_gem+1.0.1\n")
    end

    it "multiple dependencies" do
      param = [ build_version(:number => "1.0.1", :dependencies => [
        CompactIndex::Dependency.new("foo1", "=1.0.1", "ruby", "abc123"),
        CompactIndex::Dependency.new("foo2", "<2.0", "ruby", "abc123"),
      ])]
      expect(CompactIndex.info(param)).to eq("---\n1.0.1 foo1:=1.0.1,foo2:<2.0|checksum:sum+test_gem+1.0.1\n")
    end

    it "dependency with multiple versions" do
      param = [ build_version(:number => "1.0.1", :dependencies => [
        CompactIndex::Dependency.new("foo", "<2.0, >1.0", "ruby", "abc123")
      ])]
      expect(CompactIndex.info(param)).to eq("---\n1.0.1 foo:<2.0&>1.0|checksum:sum+test_gem+1.0.1\n")
    end

    it "sorts the requirements" do
      param = [ build_version(:number => "1.0.1", :dependencies => [
        CompactIndex::Dependency.new("foo", ">1.0, <2.0", "ruby", "abc123")
      ])]
      expect(CompactIndex.info(param)).to eq("---\n1.0.1 foo:<2.0&>1.0|checksum:sum+test_gem+1.0.1\n")
    end

    it "dependencies have platform" do
      param = [ build_version(:number => "1.0.1", :dependencies => [
        CompactIndex::Dependency.new("a", "=1.1", "jruby", "abc123"),
        CompactIndex::Dependency.new("b", "=1.2", "darwin-13", "abc123"),
      ])]
      expect(CompactIndex.info(param)).to eq("---\n1.0.1 a:=1.1-jruby,b:=1.2-darwin-13|checksum:sum+test_gem+1.0.1\n")
    end

    it "show ruby required version" do
      param = [ build_version(:number => "1.0.1", :ruby_version => ">1.8") ]
      expect(CompactIndex.info(param)).to eq("---\n1.0.1 |checksum:sum+test_gem+1.0.1,ruby:>1.8\n")
    end

    it "show rubygems required version" do
      param = [ build_version(:number => "1.0.1", :rubygems_version => "=2.0") ]
      expect(CompactIndex.info(param)).to eq("---\n1.0.1 |checksum:sum+test_gem+1.0.1,rubygems:=2.0\n")
    end

    it "show both rubygems and ruby required versions" do
      param = [ build_version(:number => "1.0.1", :ruby_version => ">1.9", :rubygems_version => ">2.0") ]
      expect(CompactIndex.info(param)).to eq("---\n1.0.1 |checksum:sum+test_gem+1.0.1,ruby:>1.9,rubygems:>2.0\n")
    end

    it "adds platform next to version number" do
      param = [ build_version(:number => "1.0.1", :platform => "jruby") ]
      expect(CompactIndex.info(param)).to eq("---\n1.0.1-jruby |checksum:sum+test_gem+1.0.1\n")
    end
  end
end
