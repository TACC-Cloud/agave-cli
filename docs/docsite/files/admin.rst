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

To remove all the permissions on a file, except those of the owner:             
                                                                                
.. code-block:: console

    files-pems-delete agave://system-id/some-dir
    
To edit permissions for another user, let's say her username is "collab,"       
to view a file:                                                                 
                                                                                
.. code-block:: console

    files-pems-update agave://system-id/path -u collab -p ALL -r     
                                                                                
Now, a user with username "collab" has permissions to access the all contents   
of the specified directory (``-r`` applies the permissions recursively).               
                                                                                
Valid values for setting permission are ``READ``, ``WRITE``, ``EXECUTE``,       
``READ_WRITE``, ``READ_EXECUTE``, ``WRITE_EXECUTE``, ``ALL``, and ``NONE``.     
This same action can be performed recursively on directories using ``-r | --recursive``.


File or Directory History
#########################
You can list the history of events for a specific file or folder.
This will give more descriptive information (when applicable) related to number
of retries, permission grants and revocations, reasons for failure, and hiccups
that may have occurred in a recent process.

.. code-block:: console

    files-history agave://system-id/path/to/dir
    USER          EVENT                DATE                             DESCRIPTION
    username      CREATED              2018-11-02T10:08:54.000-05:00    New directory created at https://api.sd2e.org/files/v2/media/system/system-id//path/to/dir
    username      PERMISSION_REVOKE    2018-11-30T11:22:01.000-06:00    All permissions revoked
    username      PERMISSION_GRANT     2018-12-03T10:11:07.000-06:00    OWNER permission granted to collaborator
