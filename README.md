iPlant Foundation API Command Line Interface (CLI)
===================================================

This project contains a set of Bash Shell scripts to interact with the iPlant Foundation API. The CLI contains tools for streamlining common interactions with the API and automating repetative and/or background tasks. Conventions adopted in this project follow below.


Requirements
=================

Currently only Bash and curl are required to use the Foundation API cli tools. However, in the future, the following will be required.

	* Perl
	* Python (including json.tool)
	* Java 6+

Installation
=================

No installation is necessary. Just add the bin directory to your classpath and you're ready to go.


Contents
=================

	foundation-cli
	- README.md			this file
	+ conf
		- settings.sh	settings for connecting with the api
	+ bin
		- auth			authenticate
		- apps			query and register applications
		- data			manage remote files and folders, upload data
		- transfer		move data from one location to another
		- jobs			submit and manage jobs
		- meta			create and manage metadata
		- postit		create preauthenticated, disposable urls
		- profile		query and register users
		- systems		query, monitor, and manage systems
	+ util
		- foreverauth	keeps a fresh auth token on your system at all times
		- synchup		ensures that the contents of a local folder are always backed up online
		- jobwatch		watches your currently submitted jobs for changes in status
		- shareit		pushes a file or folder into your remote storage and makes it available to the person/people you specify.


Usage
====================

All commands follow a common syntax and share the same flags `-h` for help, `-d` for debug mode, and `-v` for verbose output. Additionaly, individual commands will have their own actions and options specific to their functionality. The general syntax all commands follow is:

	<command> <action> [-hdv]
	<command> <action> [-hdv] [target]
	<command> <action> [-hdv] [options] [target]
	
Each command has built in help documentation that will be displayed when the `-h` flag is specified. The help documentation will list the actions, options, and targets available for that command.

Authentication with the API is required in most interactions and happens every time a command it called. The command will check for valid credentials in order in the following places. If it does not find valid credentials in any of the locations, it will prompt for them.

1. environment - First the clients looks for $IPLANT_USERNAME, $IPLANT_PASSWORD, and $IPLANT_TOKEN in the environment
2. $HOME/.fapi - Next they look for the same variables defined in a shadow file in the user's home directory
3. $CLI_HOME/config/settings.sh - If they are still not found, the values are read from the settings.sh file
4. prompt - if all else fails the user is prompted for their credentials and they are stored in the $HOME/.fapi file for future use.

