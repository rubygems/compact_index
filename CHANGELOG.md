## 0.9.1 (August 19, 2015)

Features:

  - Add an option to CompactIndex.versions to calculate info_checksums on the fly

## 0.9.0 (August 17, 2015)

Features:

  - Remove sort responsability from compact_index
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

  - Drop unecessary dependencies
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
