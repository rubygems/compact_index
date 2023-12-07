[![Ruby CI](https://github.com/rubygems/compact_index/actions/workflows/ci.yml/badge.svg)](https://github.com/rubygems/compact_index/actions/workflows/ci.yml)

# CompactIndex

This gem implements the response logic for the compact index format and to manage the versions file. The compact index format has three endpoints: `/names`, `/versions` and `/info/gem_name`. The versions file is a file which hold the versions in a cache-friendly way. You can see the body response formats on [this blog post](http://andre.arko.net/2014/03/28/the-new-rubygems-index-format/) from @indirect.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'compact_index'
```

And then execute:

    $ bundle

## Usage

### `/names`

To render the body for this call, all you have to do is generate a list of gems available in alphabetical order and use call `CompactIndex.names`.

```ruby
gem 'compact_index'
CompactIndex.names(%W(a_test b_test c_test))
```

### `/versions`

The body of this endpoint can be rendered calling the `CompactIndex.versions` method. It receives two parameters: a `CompactIndex::VersionsFile` object and a set of extra gems that aren't in the file yet. The gems lists should be ordered consistently by the user.

```ruby
gem 'compact_index'
# Create the object
versions_file = CompactIndex::VersionsFile.new("/path/to/versions/file")

# Get last updated date. This is used to discover what gems aren't  in the file yet
from_date = versions_file.updated_at

# Query the extra gems using the from date. Format should be as follows
extra_gems = [
  CompactIndex::Gem.new("gem1", [
    CompactIndex::GemVersion.new("0.9.8", "ruby", "abc123"),
    CompactIndex::GemVersion.new("0.9.9", "jruby", "abc123"),
  ]),
  CompactIndex::Gem.new("gem2", [
    CompactIndex::GemVersion.new("0.9.8", "ruby", "abc123"),
    CompactIndex::GemVersion.new("0.9.9", "jruby", "abc123"),
  ])
]

# Render the body for the versions response
CompactIndex.versions(versions_file, extra_gems)
```

### `/info/gem_name`

Much like `/versions`, the `/info/gem_name` expects a pre-defined structure to render the text on the screen. The lists also should be ordered by the user. This is the expected format:

```ruby
gem 'compact_index'

# Expected versions format
versions = [
  CompactIndex::GemVersion.new("1.0.1", "ruby", "abc123", "info123", [
    CompactIndex::Dependency.new("foo", "=1.0.1", "abc123"),
    CompactIndex::Dependency.new("bar", ">1.0, <2.0", "abc123"),
  ])
]
CompactIndex.info(versions)
```

### Updating the versions file

The versions file creation and update are different. When created, all versions are at the side of the gem name, which appears only on one line. When updated, the file appends the new information on the end of the file, to avoid file changes.

```ruby
gem 'compact_index'

versions_file = CompactIndex::VersionsFile.new(file_path)
last_update = versions_file.updated_at
gems = ... # Query your database, same format from `/versions` expected
versions_file.update_with(gems)
```
