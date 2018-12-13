[![Build Status](https://travis-ci.org/TACC-Cloud/agave-cli.svg?branch=develop)](https://travis-ci.org/TACC-Cloud/agave-cli)

## What is Agave?

Agave is an open platform-as-a-service built by TACC designed for scalable and
reproducible research that integrates HPC resources which can be managed
through a single API.
Agave forms part of a thriving community that empowers users to run code in a
reproducible manner, manage data efficiently, collaborate meaningfully, and 
integrate easily with third-party applications. 
TACC operates a professionally managed and supported instance of Agave as part 
of its TACC.cloud Platform.


## What is the Agave CLI?

The Agave command line interface (CLI) is a client for interacting with the
Agave platform. 
The CLI empowers you to streamline common interactions with the API and 
automating repetitive and/or background tasks. Many developers and analysts 
use it as their primary interface to TACC and other computing environments. 
By default, this distribution of the CLI is configured to work with 
TACC-hosted instances of Agave, but it can easily be adapted to support 
on-premises or other hosted Agave installations. 


## Installation

`TACC-Cloud/agave-cli` is, at this point, composed of legacy code writen in Bash, new
tooling,bug fixes, and rewrites are done in Python 3. The Python scripts make
use of [TACC/agavepy](https://github.com/TACC/agavepy).

To use `TACC/agave-cli` you'll need the following dependencies. 

	* Bash 3.2.50+
	* curl 7.2+ with TLS support
	* jq 1.5+
    * Python 3+
    * TACC/agavepy

`Agave-CLI` relies on [TACC/agavepy](https://github.com/TACC/agavepy) version
v0.8+.
To install [TACC/agavepy](https://github.com/TACC/agavepy) from source you'll
need to clone the repo and and install it as such:
```shell
git clone https://github.com/TACC/agavepy

make install
```

Once you have these requirements installed, you'll need to clone this
repository and add it to your `$PATH`.

```shell
$ git https://github.com/TACC-Cloud/agave-cli

$ cd agave-cli

$ export PATH=$PATH:$PWD/agave-cli/bin
```

To persist the new `$PATH` between logins, run
```shell
echo "export PATH=$PATH:$PWD/agave-cli/bin" >> ~/.bashrc
```
or
```shell
echo "export PATH=$PATH:$PWD/agave-cli/bin" >> ~/.bash_profile
```


## Getting started

To get more details 
[see the documentation for the latest changes](docs/docsite).
For more oficial documentation see
[Agave](https://tacc-cloud.readthedocs.io/projects/agave/en/latest/).

The first time you use the CLI, you will need to create a session.
You will need to create credentials to interact with a tenant.
The credentials will, by default, be store in `~/.agave/`.

```
$ auth-session-init 
ID                   NAME                                     URL                                               
3dem                 3dem Tenant                              https://api.3dem.org/                             
agave.prod           Agave Public Tenant                      https://public.agaveapi.co/                       
araport.org          Araport                                  https://api.araport.org/                          
designsafe           DesignSafe                               https://agave.designsafe-ci.org/                  
iplantc.org          CyVerse Science APIs                     https://agave.iplantc.org/                        
irec                 iReceptor                                https://irec.tenants.prod.tacc.cloud/             
portals              Portals Tenant                           https://portals-api.tacc.utexas.edu/              
sd2e                 SD2E Tenant                              https://api.sd2e.org/                             
sgci                 Science Gateways Community Institute     https://sgci.tacc.cloud/                          
tacc.prod            TACC                                     https://api.tacc.utexas.edu/                      
vdjserver.org        VDJ Server                               https://vdj-agave-api.tacc.utexas.edu/            

Please specify the ID for the tenant you wish to interact with:
```

After selecting a tenant to interact with, `auth-session-init` will help you
create an oauth client and obtain an access and a refresh token to get you
ready to interact with TACC apis.

For more info on `auth-session-init` see
[authentication docs](docs/docsite/authentication/auth.rst).

### Using the CLI

The Agave CLI is broken down into the following groups of scripts

	- apps*           query and register apps
	- auth*           authenticate
	- clients*        create and manage your API keys
	- files*          manage remote files and folders, upload, download, and transfer data
	- jobs*           submit and manage jobs
	- metadata*       create and manage metadata and metadata schemas
	- notifications*  subscribe to and manage event notifications from the platform
	- postits*        create pre-authenticated, disposable urls
	- profiles*       query and register users
	- systems*        query, monitor, and manage systems
	- tenants*        query and initialize the CLI for your tenant
	- uuid*           lookup and expand one or more Agave UUID

All commands follow a common syntax and share many of the same flags `-h` for help, `-d` for debug mode, `-v` for verbose output, `-V` for very verbose (prints curl command and full service response), and `-i` for interactive mode. Additionaly, individual commands will have their own options specific to their functionality. The general syntax all commands follow is:

	<command> [-hdv]
	<command> [-hdv] [target]
	<command> [-hdv] [options] [target]

Each command has built in help documentation that will be displayed when the `-h` flag is specified. The help documentation will list the actions, options, and targets available for that command.
