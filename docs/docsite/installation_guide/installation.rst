.. _installation_guide:
.. _installation:

Installation Guide
==================

.. contents:: Topics

.. _what_will_be_installed:

What will be installed
``````````````````````

In this guide we will cover how to get ``Agave-CLI`` into your machine.
We will cover how to install the latest official release.
Also, we will cover how to install the latest from the development branch in 
case you want to get the latest features and help the TACC team build the most 
useful and performant software that meets your needs.

.. _what_version:

What version to install
```````````````````````
``Agave-CLI`` is under constant development. 
Some features may be missing from oficial releases but in general oficial
releases are pushed when the project has reached a stable state.



.. _install_dependencies:

Install dependencies
++++++++++++++++++++
To work with ``Agave-CLI`` you'll need to have 
`AgavePy <https://github.com/TACC/agavepy>`_ installed in your machine.
To do this, 

.. code-block:: console

    git clone https://github.com/TACC/agavepy
    cd agavepy
    git checkout develop


If you have `GNU make <https://www.gnu.org/software/make/manual/make.html>`_
installed in your system, you can install ``AgavePy`` for Python 3 as follows:

.. code-block:: console

    make install

To install ``AgavePy`` for Python 2,

.. code-block:: console

    make install-py2

The ``Makefile`` uses the ``setup.py`` file for all installation related logic.

To install ``AgavePy`` without ``make``:

.. code-block:: console

    python setup.py install

.. _install_cli:

Install Agave-CLI
+++++++++++++++++

Once you have ``AgavePy`` installed you'll need to get the source code for
``Agave-CLI``:

.. code-block:: console

    git clone https://github.com/TACC-Cloud/agave-cli
    cd agave-cli

Once you are inside the repository, you can permanently place the cli in your
``$PATH`` by putting the following in your ``~/.bashrc`` or ``~/.bash_profile``:

.. code-block:: console

    export PATH=$PATH/<path to agave-cli repository>/bin
