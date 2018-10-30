.. _authentication:

==============                                          
Authentication
==============

To start interacting with TACC's agave platform you'll need to be
authenticated.
The authentication process involves specifying the tenant one wishes to
interact with, the creation of an Oauth client that will create and refresh
access tokens for the rest of the Agave services, and the request for the
creation of an access token and refresh token pair or the use of a refresh
token to obtain a new token pair after the tokens have expired.
We will refer to the specfication fo a tenant, client configurations, and
tokens as a session.

In this section we descrie how to use ``Agave-CLI`` to initiate, save, or
restore a session.

                                                                                
.. toctree::
    :maxdepth: 2

    auth


.. only::  subproject and html                                                  
                                                                                
   Indices                                                                      
   =======                                                                      
                                                                                
   * :ref:`genindex`
