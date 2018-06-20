## What is Agave?

[Agave] is an open Science-as-a-Service platform built by TACC and a thriving user community that empowers users to run code reproducibly, manage data efficiently, collaborate meaningfully, and integrate easily with third-party applications. TACC operates a professionally managed and supported instance of Agave as part of its TACC.cloud Platform.

## What is the Agave CLI?

The Agave command line interface (CLI) is a rich, expressive Bash client for interacting with the Agave platform. The CLI empowers you to streamline common interactions with the API and automating repetitive and/or background tasks. Many developers and analysts use it as their primary interface to TACC and other computing environments. By default, this distribution of the CLI is configured to work with TACC-hosted instances of Agave, but it can easily be adapted to support on-premises or other hosted Agave installations. collection of Bash shell scripts allowing you to interact with the Agave Platform. The CLI allows you to streamline common interactions with the API and automating repetitive and/or background tasks.


## Installation from source

The Agave CLI has the following dependencies. All must be in your `$PATH`:

	* Bash 3.2.50+
	* Python 2.7.10+
	* curl 7.2+ with TLS support
	* jq 1.5+

To install from source, clone the repository and add its `bin` directory to your `$PATH`.

```shell
$ git clone git@bitbucket.org:tacc-cic/cli.git agave-cli
$ export PATH=$PATH:`pwd`/tacc-cli/bin
```

To persist the new `$PATH` betweeon logins, add `export PATH=$PATH:`pwd`/tacc-cli/bin` to `~/.bashrc` or `~/.bash_profile`.

## Getting started

The first time you use the CLI, you will need to initialize it. This will create a credentials store inside `~/.agave/` and set your API server to point at a specific _tenant_. Tenant, in this case, refers to an organization that has its own logically-isolated slice of the hosted Agave API platform.

Initialize the CLI as follows, selecting the appropriate tenant. If you don't know which to select, choose the default. Your Agave username and password will be the same as your TACC credentials.

```shell
$ tenants-init
Please select a tenant from the following list:
[0] 3dem
[1] agave.prod
[2] araport.org
[3] designsafe
[4] iplantc.org
[5] irec
[6] sd2e
[7] sgci
[8] tacc.cloud
[9] vdjserver.org
Your choice [8]:

Your CLI is now configured to interact with APIs owned by 'tacc.cloud'.
Use 'clients-create' to set up a new API client or 'auth-tokens-create' to
re-use an existing API key and secret.
```

### Get an API Client

TACC.cloud APIs, including Agave, use an authentication called Oauth2. The basic idea is that instead of always sending your very precious password over the wire when you interact with the APIs, you send secure, but expirable strings of text in place of your password. To do this, you need to have an API client, which is a unique combination of API key and secret, and you need at least one access token.

You can have as many clients as you want, and each can have exactly one active token. Technically, clients can have different levels of access to TACC.cloud resources, but that is not currently exposed. Some users like to think of clients as "sub-accounts" of their main Agave account.

Create a client as follows. Take note of the key and secret returned, as you can use them elsewhere.

```shell
$ clients-create -S
The name of the client application : cli_docs
API username : taco
API password: *********

Successfully created client cli_docs
key: XgzF0kXZK4cRfiyslXtCfqUEgPAa
secret: tgn1Oi_8XO7JEZVDhQWtsgcLNiUa
```

These values are used behind the scenes to generate, and then refresh, your access token, which is a little string that your CLI and other clients send to the Agave authentication servers.

### Authenticate for the first time

Use your newly created client to generate a pair of tokens. One token is an *access token* which is sent over the wire in place of your password. The other is a *refresh token* which can can, in combination with the client secret and key, be used to get a new access token when the current one expires. Depending on your tenant's policy, access tokens have a lifespan of 1-4 hours.

```shell
$ auth-tokens-create -S
API password: *******
Token for tacc.cloud:taco successfully refreshed and cached for 14400 seconds
f1c972d9d4cb34faec981edbadc938d0
```

### Reauthenticating at a later date

After a while, the access token expires. This is an important security feature, since that token is being sent all over the place and might get intercepted by annoying people and used to access your resources without your permission. Getting a new one is easy. If you're using the Agave CLI or the AgavePy Python library, a good faith attempt will be made to refresh your token automatically.

If you need to manually refresh your token, do the following:

```shell
$ auth-tokens-refresh -S
Token for tacc.cloud:taco successfully refreshed and cached for 14400 seconds
cc378eac99cb171687eb6e55a85c1756
```

If this fails, run `auth-tokens-create -S` as above

### Using the CLI

The Agave CLI is broken down into the following groups of scripts

	- apps*           query and register apps
	- auth*           authenticate
	- clients*        create and manage your API keys
	- files*          manage remote files and folders, upload, download, and transfer data
	- jobs*           submit and manage jobs
	- metadata*	      create and manage metadata and metadata schemas
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
