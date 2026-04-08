[![Ruby CI](https://github.com/rubygems/compact_index/actions/workflows/rubygems.yml/badge.svg)](https://github.com/rubygems/compact_index/actions/workflows/rubygems.yml)

# CompactIndex

> **Note**: This library is being integrated directly into [rubygems.org](https://github.com/rubygems/rubygems.org). For bug reports, feature requests, and questions, please use the [rubygems.org issue tracker](https://github.com/rubygems/rubygems.org/issues).

This gem is a **server-side** library that generates responses in the compact index format. It is not a client for consuming compact index endpoints. Client implementations exist separately in [RubyGems](https://github.com/rubygems/rubygems) and [Bundler](https://github.com/rubygems/rubygems/tree/master/bundler/lib/bundler/compact_index_client).

The compact index format has three endpoints: `/names`, `/versions` and `/info/gem_name`. The versions file is a file which holds the versions in a cache-friendly way. You can see the body response formats on [the official Compact Index API guide](https://guides.rubygems.org/rubygems-org-compact-index-api/).

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

The body of this endpoint can be rendered calling the `CompactIndex.versions` method. It receives two parameters: a `CompactIndex::VersionsFile` object and a set of extra gems that aren't in the file yet. The gems should be ordered in the order they were added (i.e., chronological order of first publication).

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

Much like `/versions`, the `/info/gem_name` expects a pre-defined structure to render the text on the screen. The versions should be ordered chronologically. This is the expected format:

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

The versions file creation and update are different. When created, all versions are at the side of the gem name, which appears only on one line. When updated, the file appends the new information on the end of the file, to avoid file changes. To append new gems, use `CompactIndex.versions(versions_file, extra_gems)` as shown in the `/versions` section above.
