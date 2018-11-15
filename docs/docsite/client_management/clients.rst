Listing API subscriptions
#########################

You can list an oauth client's API subscriptions as follows:

.. code-block:: console

     $ clients-subscriptions-list 
     API password: 
     NAME             VERSION  PROVIDER 
     Apps                v2    admin     
     Files               v2    admin 
     Jobs                v2    admin   
     Meta                v2    admin    
     Monitors            v2    admin    
     Notifications       v2    admin   
     Postits             v2    admin   
     Profiles            v2    admin   
     Systems             v2    admin   
     Transforms          v2    admin   
     PublicKeys          v2    admin


If you want to specify an oauth client other than the one in your current
session, you can specify the client's name using the ``-n | --name`` flag.


Subscribing clients to an API
#############################

To subscribe an oauth client to a TACC API you can use the command
``client-subscriptions-update`` as follows:

.. code-block:: console

    $ clients-subscriptions-update -a PublicKeys -r v2 -p admin
    API password: 

If no client is specified via the ``-n | --name`` flag then
``clients-subscription-update`` will use the client in the current session by
default.
