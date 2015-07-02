require 'spec_helper'
require 'support/gem_builder'

describe CompactIndex do
  let(:builder) { GemBuilder.new($db) }

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

  describe '.versions' do
    let(:data) { "a 1.0.0,1.0.1\nb 1.0.0\nc 1.0.0-java\na 2.0.0\na 2.0.1\n" }
    before do
      allow_any_instance_of(CompactIndex::VersionsFile).to receive(:with_new_gems).and_return(data)
    end
    it "returns versions.list" do
      expect(CompactIndex.versions($db)).to eq(data)
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
