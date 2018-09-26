# Reactor Template: Python 2.7.14

A TACC Reactor defines a function to take on TACC Cloud resources in response
to a message. TACC Reactors run in the Abaco platform-as-a-service, which is
also developed and operated by TACC. This boilerplate repository gives you
all the pieces you need to build and deploy a function as a TACC Reactor.

## The function file (reactor.py)

The file `reactor.py` is where the code for your function can be found. If 
you need to add more files, extend the `Dockerfile`:

```shell
ADD mycode.py /
```

## Deployment configuration (reactor.rc)

The CLI reads from `reactor.rc` to automatically set certain attributes of 
the Reactor. Of these, only `REACTOR_NAME` is mandatory. 

## Optional configuration files

We've tried to automate the repetitive parts of deploying functions to the 
by making Reactors runtime and build processes smart (but not too clever for
their own good). The files described below unlock that automation. 

### Function configuration (config.yml)

If you import the `reactors` module as show in some of the examples, you'll 
automatically gain access to an [`AttrDict`][] named `settings` populated by the 
contents of `config.yml`. 

### Message template (message.json)

To activate automatic validation of incoming JSON messages to your Reactor 
add a valid [JSON schema][] (draft 4+) by extending the Dockerfile:

```shell
ADD message.json /
```

At present, the JSON schema *must* be named `AbacoMessage`

### Python dependencies (requirements.txt)

This is empty by default. If you have additional Python dependencies beyond
those that ship with the Reactors base image, add them here and they will be
included and built (if possible) at `deploy` time or when you manually run 
`docker build`.

### Dockerfile

All that's mandatory is the `FROM` statement. If you need to manually add 
additional code, dependencies, etc. to your Reactor, this is the place for
doing that. 

## Ignore files

We've preconfigured .dockerignore and .gitignore files for you that are
tailored towards preventing you from including sensitive information and/or
build cruft in the Docker images and git repositories used in creating Reactors.

## Secrets file

If you create a file called `secrets.json` it will never be committed to a Git 
repository or included in a Docker image build, but `abaco deploy` use it to
populate the default environment variables for the Reactor. vValues placed in this 
file are *NOT THAT SECRET* since they can be discovered by other users if you 
choose to share your Reactor.
