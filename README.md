iPlant Agave API Command Line Interface (CLI)
===================================================

This project contains a set of Bash Shell scripts to interact with the iPlant Agave API. The CLI contains tools for streamlining common interactions with the API and automating repetative and/or background tasks. Conventions adopted in this project follow below.


Requirements
=================

The following technologies are required to use the Agave API cli tools. 

	* bash
	* curl
	* Perl
	* Python (including json.tool)	
	
Installation
=================

Just clone the repository from Bitbucket and add the bin directory to your classpath and you're ready to go.

	> git clone https://bitbucket.org/taccaci/foundation-cli.git
	> export PATH=$PATH:`pwd`/foundation-cli/bin
	

Configuaration
====================
Prior to using the CLI, you will need to initialize your environment using the `tenants-init` command and selecting your organization from the list. This is a one-time process that sets the proper URL base path for your tenant and stores it in a cache file on your system. You can configure the location of the authentication cache by setting the `$AGAVE_CACHE_DIR` environment variable. The default location is `$HOME/.agave`.


Authentication
====================
Authentication with the API is done via OAuth2. The CLI will handle the authentication flow for you. Simply run the `auth-tokens-create` command and supply your client key, secret, and username & password and a bearer token will be retrieved from the auth service. Alternatively, you can specify a bearer token at the command line by providing the `-z` or `--access_token` option. If you would like to store a token for repeated use so you don't have to keep reauthenticating with every call, run the `auth-tokens-create` script with the `-S` option to store the token locally for future use. 


Contents
=================

	Agave-cli
	- README.md				this file
	+ bin
		- common.sh			global settings for connecting with the api and common functions
		- auth*				authenticate
		- apps*				query and register applications
		- jobs*				submit and manage jobs
		- postits*			create preauthenticated, disposable urls
		- profiles*			query and register users
		- systems*			query, monitor, and manage systems
		- files*			manage remote files and folders, upload data
		- transforms*		move data from one location to another
		- metadata*			create and manage metadata
		- monitors*			create and manage system monitors
		- notifications*	create and manage notifications
	+ util
		- (synchup)			ensures that the contents of a local folder are always backed up online
		- (jobwatch)		watches your currently submitted jobs for changes in status
		- (shareit)			pushes a file or folder into your remote storage and makes it available to the person/people you specify.


Usage
====================

All commands follow a common syntax and share many of the same flags `-h` for help, `-d` for debug mode, `-v` for verbose output, `-V` for very verbose (prints curl command), and `-i` for interactive mode. Additionaly, individual commands will have their own options specific to their functionality. The general syntax all commands follow is:

	<command> [-hdv]
	<command> [-hdv] [target]
	<command> [-hdv] [options] [target]
	
Each command has built in help documentation that will be displayed when the `-h` flag is specified. The help documentation will list the actions, options, and targets available for that command.