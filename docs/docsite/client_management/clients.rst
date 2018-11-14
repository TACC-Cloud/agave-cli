Listing API subscriptions
#########################

Subscribing clients to an API
#############################

To subscribe an oauth client to a TACC API you can use the command
``client-subscriptions-update`` as follows:

.. code-block:: console

    $ clients-subscriptions-update -a PublicKeys -r v2 -p admin
    API password: 

If no client is specified viathe ``-n | --name`` flag then
``clients-subscription-update`` will use the client in the current session by
default.
