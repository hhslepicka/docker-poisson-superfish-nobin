
# Poisson Superfish via Docker

A docker image with Poisson Superfish built-in via Wine.

# Disclosure
> :warning: I am not responsible in any way, shape or form for what you do with this container
and binary files.
If you end up uploading your image to DockerHub please make sure to make it `private`
as to not break the license terms of Poisson Superfish.
>
>Only proceed if you agree to the terms above.

## How to build the container

Due to restrictions on Poisson Superfish license, we can't distribute the binaries
along with this container.

Here are the steps that you will need in order to properly build this container
and use it:

- Go into Poisson Superfish website and download the file.
- Using a Windows machine, install it and copy the binary files from the 
installation folder into a folder called `PoissonSuperfish`.
- Make a tarball of this folder with:
```shell script
tar -czvf superfish.tar.gz PoissonSuperfish
```
- Copy the `superfish.tar.gz` file into this folder
- Run the Docker build command
```shell script
docker build -t <your dockerhub username>/poisson-superfish .
```
- Use the container according to the instructions below.

## How to run the container

This container allow you to run Poisson Superfish tools in two ways:

- Batch mode: all executions are handled internally, screens are not available.
- Interactive mode: the expected screens will be displayed and the process will
only finish when closing the screen.

### Batch mode

For batch mode no extra dependencies are required.

```shell script
docker run -it --rm \
-v /home/slepicka/data:/data/ \
<your dockerhub username>/poisson-superfish:latest automesh /data/test.am
```

### Interactive Mode

The interactive mode is controlled via the `INTERACTIVE_FISH` environment variable.
This variable can be defined via docker run command or at any time inside the container.

When running with `INTERACTIVE_FISH`, by default the screen will be scaled to 1024x768.
To control this behavior you can tweak the `SCALED_FISH` variable which controls the
overall scaling process. When this variable is 1 (Default) scaling will be applied,
otherwise no scaling is performed and the resolution is controlled by your X Server.
To tune the desired resolution via the `RESOLUTION_FISH` variable (Default 1024x768).

E.g.:
```shell script
$ docker run --rm -ti \
-u $(id -u):$(id -g) \
-e INTERACTIVE_FISH=1 \
-e SCALED_FISH=1 \
-e RESOLUTION_FISH="800x600" \
-e DISPLAY=unix$DISPLAY \
-v "/tmp/.X11-unix:/tmp/.X11-unix" \
-v "/etc/group:/etc/group:ro" \
-v "/etc/passwd:/etc/passwd:ro" \
<your dockerhub username>poisson-superfish <cmd> <args>
```

Since Poisson Superfish can use a graphical interface, you need to pass additional arguments in
order to properly forward X:

#### Linux:
```shell script
$ docker run --rm -ti \
-u $(id -u):$(id -g) \
-e INTERACTIVE_FISH=1 \
-e DISPLAY=unix$DISPLAY \
-v "/tmp/.X11-unix:/tmp/.X11-unix" \
-v "/etc/group:/etc/group:ro" \
-v "/etc/passwd:/etc/passwd:ro" \
<your dockerhub username>/poisson-superfish <cmd> <args>
```

#### MacOS:

First install XQuartz. Then run it from the command line using `open -a XQuartz`.
In the XQuartz preferences, go to the “Security” tab and make sure you’ve got
“Allow connections from network clients” ticked. Restart XQuartz.

```shell script
$ IP=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
$ xhost + $IP
$ docker run --rm -ti -e INTERACTIVE_FISH=1 -e DISPLAY=$IP:0 <your dockerhub username>/poisson-superfish <cmd> <args>
```

#### Windows:

First, install an X server such as the one available in MobaXterm. Run Moba and ensure that the X server is running.
Then:

```shell script
C:\> docker run --rm -ti -e INTERACTIVE_FISH=1 -e DISPLAY=host.docker.internal:0.0 <your dockerhub username>/poisson-superfish <cmd> <args>
```

## Sharing a folder with the container

In order to share a folder with your container you need to add an extra parameter
to the way it is launched.

The extra parameter is in the following format: `-v <local path>:<container path>`.
E.g.: To share a folder on linux `/tmp/data` with the container and have it at `/data/`
you need to specify `-v /tmp/data:/data`.

For more information on shared folders please read the 
[Docker documentation for volumes](https://docs.docker.com/storage/volumes/#start-a-container-with-a-volume).

## Changing default work directory

The default work directory is `/`. In order to change that you
need to specify an extra parameter at the launching script: `--workdir <container path>`

## Running with an user other than root
By default the container will run as root, which may cause some issues when
a folder is shared with the container and files are modified.
One suggestion valid for Linux and macOS to specify the UID and 
GID for the container is to use the `-u` parameter:
`-u $(id -u):$(id -g)`.

At a Linux system it is possible to share as ReadOnly the group and passwd files
so the container will present the correct values for the username and group. For
macOS I couldn't find a way to accomplish that yet.

#### Linux sharing group and passwd
```shell script
$ docker pull <your dockerhub username>/poisson-superfish:latest
$ docker run \
--rm -ti \
-u $(id -u):$(id -g) \
-v "/etc/group:/etc/group:ro" \
-v "/etc/passwd:/etc/passwd:ro" \
<your dockerhub username>/poisson-superfish
```

## Examples

Here is an example on how to launch `automesh` for a file called `test.am` located
at `/home/slepicka/data` using macOS.

### Batch mode

```shell script
docker run -it --rm \
-v /home/my_user/data:/data/ \
<your dockerhub username>/poisson-superfish:latest \
automesh /data/test.am
```

### Interactive mode

```shell script
IP=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
host + $IP

docker run -it --rm \
-v /home/my_user/data:/data/ \
-e DISPLAY=$IP:0 \
<your dockerhub username>/poisson-superfish:latest automesh /data/test.am
```

### Launching a Bash Shell
```shell script
docker run -it --rm \
-v /home/my_user/data:/data/ \
<your dockerhub username>/poisson-superfish:latest \
/bin/bash
```

## Running the Container at NERSC

NERSC uses Shifter instead of Docker to run containers. More information on Shifter
can be found [here](https://docs.nersc.gov/development/shifter/how-to-use/).

Assuming that you followed the procedure above, it will be required of you to 
push your image to DockerHub (please remember to make it PRIVATE) before fetching
it and using it at NERSC.

- Pushing the latest version of image to DockerHub (Always build before pushing)
```shell script
docker build -t <your dockerhub username>/poisson-superfish .
docker push <your dockerhub username>/poisson-superfish:latest
```

- Log into one of the NERSC nodes (one of the login nodes are fine)
- Add your DockerHub credentials to Shifter
```shell script
shifterimg login hub.docker.com
```
- Pull the image giving permission to your NERSC user ONLY:
```shell script
shifterimg --user my_user pull <your dockerhub username>/poisson-superfish:latest
```
- Allocate an interactive session to play with it the first time
```shell script
salloc -N 1 -C haswell -q interactive -t 04:00:00 --image=<your dockerhub username>/poisson-superfish:latest
```
- Run `automesh` for a demo file
```
shifter automesh test.am
```

## Using pySuperfish With Your Container

[pySuperfish](https://github.com/ChristopherMayes/pySuperfish) is a Python wrapper 
around Poisson Superfish that can be used with or without the container.

Here is how to configure it to use your custom container:
```python
from pysuperfish import Superfish
Superfish._container_image = "<your dockerhub username>/poisson-superfish"
```

After the step above you will be good to use 