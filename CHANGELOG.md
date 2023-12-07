
## 0.14.0 (May 25, 2020)

Enhancement:

  - Add timestamp arg to version file create function

## 0.13.0 (May 25, 2020)

Bugfix:

  - Revert trimming of space from requirements. Removing space would have meant info response of all gems were going to change.
  - Fix token used for splitting list of requirements

## 0.12.0 (May 3, 2020)

Bugfix:

  - Update info line to join multiple ruby or rubygems requirements by ampersand (rubygems/compact_index#26)

## 0.11.0 (January 22, 2016)

Features:

  - Refactoring big part of the code
  - Change behavior of VersionsFile#create to avoid adding multiple versions per line

## 0.10.0 (January 22, 2016)

Features:

  - Frozen string literal support

Bugfixes:

  - Use the last info checksum, rather than the first

## 0.9.4 (January 5, 2016)

Features:

  - YARD documentation

Bugfixes:

  - Use versions.list header time instead of mtime



## 0.9.3 (August 25, 2015)

Features:

  - Support for ruby 1.8

## 0.9.3 (August 25, 2015)

Features:

  - Support for ruby 1.8

## 0.9.2 (August 22, 2015)

Features:

  - Parameters from versions are now optional

## 0.9.1 (August 19, 2015)

Features:

  - Add an option to CompactIndex.versions to calculate info_checksums on the fly

## 0.9.0 (August 17, 2015)

Features:

  - Remove sort responsibility from compact_index
  - Change interface for versions_file in order to receive sorted gems


## 0.8.1 (August 13, 2015)

Bugfixes:

  - deal with nil created_at when sorting on info

## 0.8.0 (August 13, 2015)

Features:

  - Change info file interface to accept create_at
  - Order info output accordingly to version create_at

## 0.7.0 (August 4, 2015)

Features:

  - Change versions file interface to receive separated number and platform

## 0.6.0 (August 1, 2015)

Features:

  - Change info and versions interface to receive separated number and version

## 0.5.2 (July 20, 2015)

Bugfixes:

  - Move update logic from bundler-api to here
  - Remove unused files imported on V0.1.0


## 0.5.1 (July 13, 2015)

Bugfixes:

  - Move update logic from bundler-api to here
  - Remove unused files imported on V0.1.0

## 0.4.1 (July 13, 2015)

Bugfixes:

  - Drop unnecessary dependencies
  - Remove unused files imported on V0.1.0

## 0.4.0 (July 10, 2015)

Features:

  - Change versions interface to receive a versions file
  - Add checksum on info endpoint
  - Add platform on info endpoint
  - Add checksum for versions endpoint

Refactoring:

  - Dry tests

## 0.3.1 (July 5, 2015)

Features:

  - Change versions interface to receive a versions file

Bugfixes:

  - Fix missing colon on info endpoint

## 0.3.0 (July 5, 2015)

Features:

  - Use trailing newlines on versions file and web responses
  - Remove database from project
  - Add VersionsFile#update
  - Add info, names and versions endpoints

## 0.2.0 (June 26, 2015)

Features:

  - Moved code from bundler-api to this gem
  - Configure gemspec info
  - Exposed VersionsFile and GemInfo classes
  - Add versions.list file
  - Configure travis
