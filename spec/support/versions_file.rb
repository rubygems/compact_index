require "spec_helper"
require "compact_index/versions_file"

def with_versions_file(path)
  old_path = CompactIndex::VersionsFile::PATH
  CompactIndex::VersionsFile.send(:remove_const, "PATH")
  CompactIndex::VersionsFile.const_set("PATH", path)
  yield
  CompactIndex::VersionsFile.send(:remove_const, "PATH")
  CompactIndex::VersionsFile.const_set("PATH", old_path)
end
