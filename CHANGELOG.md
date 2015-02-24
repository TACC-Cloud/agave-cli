# Change Log
All notable changes to this project will be documented in this file.

## 2.1.0 - 2015-02-23
### ADDED
- `*-addupdate` Adding support for reading from stdin to all the scripts that previously accepted only files by replacing the file name with `-`
- `jobs-template` adding webhook url with [Agave RequestBin](http://requestbin.agaveapi.co/) valid for 24 hours created on each request.
- `jobs-template` added support for parsing most enum values, properly creating arrays vs primary types based on min and max cardinality, and the ability to populate with random default values, including inputs

### FIXED
- Fixed existence check on all commands accepting files/folder inputs.

### REMOVED
- No changes.


## 2.1.0 - 2015-02-22
### ADDED
- `files-publish` **New** script providing a single command to upload a file/folder and create a public PostIt URL that can be shared. All arguments of the `files-upload` and `postits-create` commands are supported.
- `jobs-output-list` **New** script replaces the default directory listing behavior of the `jobs-output` command.
- `jobs-output-get` **New** script replaces the download behavior of the `jobs-output` command. This script supercedes the previous command by adding recursive directory downloads, range query support, and optional printing to standard out.

### FIXED
- No changes.

### REMOVED
- `jobs-output` has been deprecated and now delegates all calls to the `jobs-output-list` and `jobs-output-get` commands.


## 2.0.0 - 2014-12-10
### ADDED
- `clients-create` Broke client JSON into individual command line arguments.
- `tenants-init` Added ability to specify tenant by id or name.

### FIXED
- `tenants-init` Fixed a bug where the tenant id given at the command line was not being recognized.

### REMOVED
- No changes.
