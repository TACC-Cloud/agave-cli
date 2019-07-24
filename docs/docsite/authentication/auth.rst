.. _auth:


Initiating a session
####################

Each user creates one or more Oauth clients using the Tapis ``clients``
service. Each ``client`` consists of a name, an API key, an API secret, and
a set of subscriptions. By default each client is subscribed to (meaning they
are able to use and interact with) all public Tapis APIs. A request to a Tapis
API includes the API key and secret and a short string called an **access token**

In this documentation, we define a distinct combination of tenant, username,
client, and tokens as a **session**. The ``Tapis-CLI`` allows a user to readily
swap between multiple identities, a feature that will be detailed later.

Sessions are cached on the local host. You can re-use Oauth clients on other
hosts but we find it to be more cumbersome than simply creating per-host
sessions.

Begin by initiating a new session as follows

.. code-block:: console

    $ auth-session-init
    Client does not exist. Creating one...
    Name was not specified. Using *nearly-new-rodent*
    ID                   NAME                                     URL
    3dem                 3dem Tenant                              https://api.3dem.org/
    agave.prod           Agave Public Tenant                      https://public.agaveapi.co/
    araport.org          Araport                                  https://api.araport.org/
    bridge               Bridge                                   https://api.bridge.tacc.cloud/
    designsafe           DesignSafe                               https://agave.designsafe-ci.org/
    iplantc.org          CyVerse Science APIs                     https://agave.iplantc.org/
    irec                 iReceptor                                https://irec.tenants.prod.tacc.cloud/
    portals              Portals Tenant                           https://portals-api.tacc.utexas.edu/
    sd2e                 SD2E Tenant                              https://api.sd2e.org/
    sgci                 Science Gateways Community Institute     https://sgci.tacc.cloud/
    tacc.prod            TACC                                     https://api.tacc.utexas.edu/
    vdjserver.org        VDJ Server                               https://vdj-agave-api.tacc.utexas.edu/

    Please specify the ID for the tenant you wish to interact with: tacc.prod
    Tapis Username:
    Tapis Password:
    Client *nearly-new-mink* created
    Creating an access token for nearly-new-mink...
    518167bdae13bdfc83390e8c0a8ffb

At this point, you are ready to interact with the other Tapis services.

Creating an alternate session
#############################

If you need to create a new session, you can re-run ``auth-session-init`` with
any combination of valid values for ``--tenant``, ``--username``, and
``--name``. For instance, this creates a session for the **designsafe** tenant.

.. code-block:: console

    $ auth-session-init --tenant designsafe
    Client does not exist. Creating one...
    Name was not specified. Using *yearly-noted-clam*
    Tapis Password for vaughn:
    Client *yearly-noted-clam* created
    Creating an access token for yearly-noted-clam...
    68f326f056dbf8c1a1bc0cb7e20949a

Switching sessions
##################

The ``auth-sessions-list`` command shows the complete set of cached sessions,
as well as identifying which one is active:

.. code-block:: console

    $ auth-sessions-list
    TENANT           USERNAME     CLIENT                                   ACTIVE
    designsafe       vaughn       yearly-noted-clam                        1
    tacc.prod        vaughn       nearly-new-rodent                        0

Swap between sessions using ``auth-session-switch`` like so:

.. code-block:: console

    $ auth-session-switch -t tacc.prod -N nearly-new-rodent
    Refreshing access token for nearly-new-rodent...
    518167bdae13bdfc83390e8c0a8ffb

Sometimes you need to manually create or refresh a session access token. This
is accomplished by the ``auth-tokens-create`` and ``auth-tokens-refresh``
commands.

.. code-block:: console

    $ auth-tokens-create
    Creating access token...
    Tapis Password for vaughn:
    518167bdae13bdfc83390e8c0a8ffb
    $ auth-tokens-refresh
    Refreshing access token...
    8339e13b7bda0a8ffbdfc0e8c51816
    New token expires: Wed Jul 24 01:02:14 CDT 2019

If you are scripting in the shell and need ready access to the current
access token, ``auth-tokens-view`` is your go-to command. It fetches and
prints **only** the token to STDOUT, making it easy to capture in a variable.

.. code-block:: console

    $ TOKEN=$(bin/auth-tokens-show); echo $TOKEN
    518167bdae13bdfc83390e8c0a8ffb

Manually managing Oauth clients
###############################

On rare occasion, especially if you have manually specified the name of the
Oauth client, you may find that past you has already created an instance of
that client, preventing it from being created anew via ``auth-session-init``.
The ``clients-*`` commands allow you to list and interact with (including
delete!) specific Oauth clients.

.. code-block:: console

    $ clients-list -t tacc.prod -u vaughn
    Tapis Password:
    NAME                           DESCRIPTION
    DefaultApplication
    demo_abaco
    Fjall-5                        Autogenerated 2019-07-17T21:23:04Z
    nearly-new-rodent              Autogenerated 2019-07-24T02:05:11Z

Let's assume you want to recreate ``DefaultApplication``. Delete it like so:

.. code-block:: console

    $ clients-delete -N DefaultApplication -t tacc.prod
    Tapis Password:
    Client was deleted.

Now, it can be regenerated as follows:

.. code-block:: console

    $ auth-session-init --name DefaultApplication --tenant tacc.prod
    Loading DefaultApplication for vaughn from tacc.prod
    Unable to load client from session cache
    Client does not exist. Creating one...
    Tapis Password for vaughn:
    Client *DefaultApplication* created
    Creating an access token for DefaultApplication...
    4bcd6ab86b1bd1c5db5349c8c63ebfa

Session cache
#############

We've mentioned that session information is stored in a cache. You have control
over the location of the session cache directory. The location for
the session cache is established by looking at the environment variable
``TAPIS_CACHE_DIR``, followed by ``AGAVE_CACHE_DIR``, then defaulting to
``$HOME/.agave``. For any ``Tapis-CLI`` command that supports the ``--cachedir``
option (eventually all of them), the cache location can be over-ridden on a
per-command basis.

