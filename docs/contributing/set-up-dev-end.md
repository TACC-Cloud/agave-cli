### Work with a development container


In this section, you learn to develop like the TACC team.
The `TACC-Cloud/agave-cli` repository includes a `Dockerfile` at its root.
This file defines Agave-CLI's development environment.
The `Dockerfile` lists the environment's dependencies: system libraries and
binaries, environment, dependencies, etc.

Agave-CLI's development environment is itself, ultimately a Docker container.
You use the `TACC-Cloud/agave-cli` repository and its `Dockerfile` to create a
Docker image, run a Docker container, and develop code in the container.

If you followed the procedures that [set up Git for contributing](set-up-git.md),
you should have a fork of the `TACC-Cloud/agave-cli` repository.
You also created a branch called `dry-run-test`. In this section, you continue
working with your fork on this branch.



## Task 1. Start a development container

In this section, you will run a development container.
This worflow is automated for you by the Makefile in the root of the
repository.

1. Open a terminal.

2. Change into the `agave-cli` repository.
   ```
   $ cd ~/repos/agave-cli
   ```
   If you are following along with this guide, you created a `dry-run-test`
   branch when you [set up Git for contributing](set-up-git.md).

3. Ensure you are on our `dry-run-test` branch.
   ```
   $ git checkout dry-run-test
   ```
   If you get a essage that the branch doesn't exist, add the `-b` flag (`git
   checkout -b dry-run-test`) so the comand creates the branch and checks it
   out.

4. Use `make` to build a development environment image and run it in a
   continer.
   ```
   $ make shell
   ```
   Using the instructions in the `Dockerfile`, the build may need to download 
   and / or configure source and other images.
   A successful build returns a final message and opens a Bash shell into the
   container.
   ```
   Successfully built b25e7e3fdef0
   Successfully tagged agave-cli:add-development-container-py3-7
   docker run --rm -it -v "/home/user/repos/github.com/alejandrox1/agave-cli":/agave-cli "agave-cli:add-development-container-py3-7" bash
   root at 2af804gd82b1 in /agave-cli on dry-run-test
   ```

5. List the contents of the current directory (`/agave-cli`).
   You should see the image's source from the `/agave-cli` directory.
   
6. Run the tests to make sure everything is set up properly.
   ```
   make tests
   ```

## Task 2. Make a code change
At this point, you have:

* forked and clones the agave-cli code repository
* created a feature branch for development
* created and started an agave-cli development container from your branch
* ran the tests inside your development container

Running the `make shell` comand mounted your local agave-cli repository source
into the development container.

> If you inspect the `Makefile` you'll notice that the current
> working directory _will_ be mounted via a `-v` volume mount.

When you start to develop code though, you'll want to iterate code changes and
test runs inside the container. If you have followed this guide exactly, you
have a bash shell running a development container.

Try a simple code change and see it reflected in your container. For this
example, you'll edit the help for the `attach` subcommand.

1. If you don't have one, open a terminal in your local host.

2. Change to you `agave-cli` repository.
   ```
   $ cd ~/repos/agave-cli
   ```

3. Open the `Makefile`.

4. Make a change to the `Makefile`. 
   For example, add the following:
   ```
   hello:
       @echo "Hello world!"
   ```

5. Save the changes made to the `Makefile`.

6. Go to your running docker development container shell.

7. Run the following command:
   ```
   $ make hello
   ```

You've just done the basic workflow for changing the agave-cli code base.
You made your code changes in your feature branch. Then, you tried your change
out inside the development container. If you were making a bigger change, you
might repeat or iterate through this flow several times.


## Where to go next
Congratulations, you have successfully completed the basics you need to
contribute to the Agave-CLI project.
