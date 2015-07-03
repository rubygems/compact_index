require 'tempfile'
require 'spec_helper'

describe CompactIndex do
  it 'has a version number' do
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
      gems = [{ name: "test", versions: [{ created_at: Time.now, number: "1.0" }] }]
      expect(
        CompactIndex.versions(file.path, gems)
      ).to eq(
        CompactIndex::VersionsFile.new(file.path).contents(gems)
      )
    end
  end

  describe '.info' do
    it "without dependencies" do
      param = [{number: '1.0.1'}]
      expect(CompactIndex.info(param)).to eq("---\n1.0.1\n")
    end

    it "multiple versions" do
      param = [{number: '1.0.1'}, {number: '1.0.2'}]
      expect(CompactIndex.info(param)).to eq("---\n1.0.1\n1.0.2\n")
    end

    it "one dependency" do
      param = [{number: '1.0.1', dependencies: [
        {gem: 'foo', version: '=1.0.1'}
      ]}]
      expect(CompactIndex.info(param)).to eq("---\n1.0.1 foo=1.0.1\n")
    end

    it "multiple dependencies" do
      param = [{number: '1.0.1', dependencies: [
        {gem: 'foo1', version: '=1.0.1'},
        {gem: 'foo2', version: '<2.0'}
      ]}]
      expect(CompactIndex.info(param)).to eq("---\n1.0.1 foo1=1.0.1,foo2<2.0\n")
    end

    it "dependency with multiple versions" do
      param = [{number: '1.0.1', dependencies: [
        {gem: 'foo', version: '>1.0, <2.0'},
      ]}]
      expect(CompactIndex.info(param)).to eq("---\n1.0.1 foo>1.0&<2.0\n")
    end

    it "dependencies on alphabetic order" do
      param = [{number: '1.0.1', dependencies: [
        {gem: 'b', version: '=1.2'},
        {gem: 'a', version: '=1.1'},
      ]}]
      expect(CompactIndex.info(param)).to eq("---\n1.0.1 a=1.1,b=1.2\n")
    end
  end
end
