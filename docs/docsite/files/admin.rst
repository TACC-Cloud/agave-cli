##############
Managing Files
##############

Managing permissions
####################
Use ``files-pems-list`` to list the user permissions associated with a file or
folder. These permissions are set at the API level and do not reflect unix-like
or other file system ACL.

.. code-block:: console

    files-pems-list agave://system-id/some-dir
    USER     READ   WRITE  EXEC
    username yes    yes    yes

To edit permissions for another user, let's say her username is "collab,"       
to view a file:                                                                 
                                                                                
.. code-block:: console

    files-pems-update agave://system-id/path -u collab -p ALL -r     
                                                                                
Now, a user with username "collab" has permissions to access the all contents   
of the specified directory (``-r`` applies the permissions recursively).               
                                                                                
Valid values for setting permission are ``READ``, ``WRITE``, ``EXECUTE``,       
``READ_WRITE``, ``READ_EXECUTE``, ``WRITE_EXECUTE``, ``ALL``, and ``NONE``.     
This same action can be performed recursively on directories using ``-r | --recursive``.
