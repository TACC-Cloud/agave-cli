.. _authentication:

==============
Authentication
==============

To start interacting with the Tapis platform you'll need to be
authenticated. The authentication process involves selecting one of
several logically-isolated tenants to interact with, creating an Oauth
client that acts as a proxy for one's username and password, as well as
defining which APIs one will interact with using the CLI, and the initial
issuing of two tokens. One is an access token, which is redeemed in place of
any secret credentials to authorize access to Tapis APIs and the other is a
refresh token, which allows the access token to be regnerated when it expires.

In this section we describe using how to use ``Tapis-CLI`` to initiate, save,
and restore a session.

.. toctree::
    :maxdepth: 2

    oauth
    auth


.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
