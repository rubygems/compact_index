require 'spec_helper'
require 'support/gem_builder'

describe CompactIndex do
  let(:builder) { GemBuilder.new($db) }

  it 'has a version number' do
    expect(CompactIndex::VERSION).not_to be nil
  end

  describe '.names' do
    before do
      %w(a b c d).each {|gem_name| builder.create_rubygem(gem_name) }
    end
    it "returns the gems list" do
      expected_output = "---\na\nb\nc\nd\n"
      expect(CompactIndex.names($db)).to eq(expected_output)
    end
  end

  describe '.versions' do
    let(:data) { "a 1.0.0,1.0.1\nb 1.0.0\nc 1.0.0-java\na 2.0.0\na 2.0.1" }
    before do
      allow_any_instance_of(CompactIndex::VersionsFile).to receive(:with_new_gems).and_return(data)
    end
    it "returns versions.list" do
      expect(CompactIndex.versions($db)).to eq(data)
    end
  end

  describe '.info' do
    before do
      rack_id = builder.create_rubygem("rack")
      builder.create_version(rack_id, "rack")
      rack_101 = builder.create_version(rack_id, 'rack', '1.0.1')
      [['foo', '= 1.0.0'], ['bar', '>= 2.1, < 3.0']].each do |dep, requirements|
        dep_id = builder.create_rubygem(dep)
        builder.create_dependency(dep_id, rack_101, requirements)
      end
    end

    let(:expected_deps) do
      <<-DEPS.gsub(/^ */, '')
        ---
        1.0.0
        1.0.1 bar:>= 2.1&< 3.0,foo:= 1.0.0
      DEPS
    end

    it "should return the gem list" do
      expect(CompactIndex.info($db, 'rack')).to eq(expected_deps)
    end
  end
end
