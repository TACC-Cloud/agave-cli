.. _files:


Listing files and navigating
############################

To list the files available to you on a storage system, use:

.. code-block:: console

    $ files-list agave://tacc-data
    ./                 .slurm/            apps/              benchmarks/        cptests
    users/             myotherfile        data-dir/          old-sd2e-apps/     rpmbuild/
    sd2e-apps/         sd2e-data/         singularity-test/  SP1-copy.fq        SP1.fq
    tests/             


The ``-l`` flag provides a long listing (similar to ``ls -l`` in Linux).

.. code-block:: console

    $ files-list -l agave://tacc-data
    drwx  4096 Nov  2 10:08 ./
    drwx  4096 May 25 16:13 .slurm/ 
    drwx  4096 Jun  5 10:14 apps/
    drwx  4096 Jun  9 18:39 benchmarks/ 
    drwx  4096 Jul 13 09:17 cptests/   
    drwx  4096 Aug  1 14:26 users/ 
    -rw-    24 Oct 25 14:42 myotherfile  
    drwx  4096 Nov  2 10:08 data-dir/
    drwx  4096 Jul 10 11:27 old-sd2e-apps/
    drwx  4096 Jun 29 10:40 rpmbuild/ 
    drwx  4096 Jul 13 15:41 sd2e-apps/
    drwx  4096 Jul  7 20:43 sd2e-data/   
    drwx  4096 Jul  9 16:50 singularity-test/ 
    -rw- 22471 Aug 22 14:40 SP1-copy.fq     
    -rw- 22471 Jul  7 20:42 SP1.fq 
    drwx  4096 Oct 31 14:15 tests/


Deleting files or folders
#########################

To remove a folder, use the ``files-rm`` command:

.. code-block:: console

    $ files-rm agave://data-tacc-work-username/sd2e-data/

**WARNING**: The ``files-rm`` command will delete folders with or without
contents.


Moving or renaming files and directories
########################################

Similarly, if you want to move (rename) a file or directory you can use
``files-mv``:

.. code-block:: console

    $ files-mv agave://data-tacc-work-username/sd2e-data/renamed.txt \
        agave://data-tacc-work-username/sd2e-data/renamedfolder/renamed.txt

``files-md`` behaves similar to the GNU/Linux command ``mv``. The first
argument most be the file you want to move and the second its new location or
name.


Uploading and downloading via the CLI
#####################################

Files can be transferred from your local machine to the remote storage system
and from the remote storage system to your local machine using the 
``files-cp`` command.

First, find or create a local file and upload it to the storage system:

.. code-block:: console

    $ touch my_file.txt
    $ echo 'Hello, world!' > my_file.txt
    $ files-cp my_file agave://data-tacc-work-username/sd2e-data/
    
    $ files-list -l agave://data-tacc-work-username/sd2e-data/
    drwx------  username  4096  15:53  .
    -rw-------  username  0     15:53  my_file.txt


To make a copy of the file on the remote storage system:

.. code-block:: console

    $ files-cp agave://data-tacc-work-username/sd2e-data/my_copy.txt \
            agave://data-tacc-work-username/sd2e-data/my_file.txt

    $ files-list -l agave://data-tacc-work-username/sd2e-data/
    drwx------  username  4096  15:57  .
    -rw-------  username  0     15:57  my_copy.txt
    -rw-------  username  0     15:53  my_file.txt


Then, download the result:

.. code-block:: console

    $ files-cp agave://data-tacc-work-username/sd2e-data/my_copy.txt file.txt

    $ ls
    file.txt  my_file.txt
