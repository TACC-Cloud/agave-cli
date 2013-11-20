iPlant Foundation API Command Line Interface (CLI)
===================================================

This project contains a set of Bash Shell scripts to interact with the iPlant Foundation API. The CLI contains tools for streamlining common interactions with the API and automating repetative and/or background tasks. Conventions adopted in this project follow below.


Requirements
=================

The following technologies are required to use the Foundation API cli tools. 

	* bash
	* curl
	* Perl
	* Python (including json.tool)	
	
Installation
=================

No installation is necessary. Just add the bin directory to your classpath and you're ready to go.

	export PATH=$PATH:/path/to/foundation-cli/bin
	

Contents
=================

	foundation-cli
	- README.md			this file
	+ bin
		- common.sh		global settings for connecting with the api and common functions
		- auth*			authenticate
		- apps*			query and register applications
		- jobs*			submit and manage jobs
		- postits*		create preauthenticated, disposable urls
		- profiles*		query and register users
		- systems*		query, monitor, and manage systems
		- files*		manage remote files and folders, upload data
		- (transfers*)	move data from one location to another
		- (transforms*)	move data from one location to another
		- (meta*)			create and manage metadata
	+ util
		- (synchup)		ensures that the contents of a local folder are always backed up online
		- (jobwatch)		watches your currently submitted jobs for changes in status
		- (shareit)		pushes a file or folder into your remote storage and makes it available to the person/people you specify.


Usage
====================

All commands follow a common syntax and share the same flags `-h` for help, `-d` for debug mode, `-v` for verbose output, and `-i` for interactive mode. Additionaly, individual commands will have their own options specific to their functionality. The general syntax all commands follow is:

	<command> [-hdv]
	<command> [-hdv] [target]
	<command> [-hdv] [options] [target]
	
Each command has built in help documentation that will be displayed when the `-h` flag is specified. The help documentation will list the actions, options, and targets available for that command.

Authentication with the API is required in most interactions and happens every time a command it called. Authentication credentials can be specified at the command line using the `--apisecret` and `-apikey` options. It is recommended that the key be entered in interactive mode for security purposes. If you would like to store a token for repeated use so you don't have to keep reauthenticating with every call, call the `auth-tokens-create` script with the `-S` option to store the token locally for future use.
