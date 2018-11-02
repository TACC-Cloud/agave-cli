.. _files:


Listing files and navigating
############################

To list the files available to you on a storage system, use:

.. code-block:: console

    $ files-list agave://tacc-globalfs-username
    ./                 .slurm/            apps/              benchmarks/        cptests
    users/             myotherfile        data-dir/          old-sd2e-apps/     rpmbuild/
    sd2e-apps/         sd2e-data/         singularity-test/  SP1-copy.fq        SP1.fq
    tests/             


The ``-l`` flag provides a long listing (similar to ``ls -l`` in Linux).

.. code-block:: console

    $ files-list -l agave://tacc-globalfs-username
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
