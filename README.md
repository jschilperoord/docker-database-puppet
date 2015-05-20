## Oracle Database 11.2.0.4 ( 11g ) Standard Edition Docker image

This is based on the great work from Edwin Biemond on his docker-database-puppet image.

It will download a minimal Oracle Linux 6 image, Puppet 3.7 and all it dependencies

The Docker image will be big, and off course this is not supported by Oracle and like always check your license to use this software

Configures Puppet and use librarian-puppet to download all the modules from the Puppet Forge

### Result
- Oracle Database Standard Edition 11.2.0.4
- Service name = orcl.example.com
- username sys or system
- All passwords = Welcome01
- Demo schemas

Optional, you can add your own DB things, just change the puppet site.pp manifest
- Add your own Tablespaces
- Add Roles
- User with grants
- Change database init parameters
- execute some SQL

### Software
Download the oracle zips from Oracle support for Oracle 11.2.0.4

Add them to this docker folder

### Build image (~ 13GB)
docker build -t oracle/database11204 .

Maybe after the build you should compress it first, see the compress section for more info

### Start container
default, will start the listener & database server
- docker run -i -t -p 1521:1521 oracle/database11204:latest

with bash

docker run -i -t -p 1521:1521 oracle/database11204:latest /bin/bash
- /startup.sh

### Compress image (now ~7.6GB)
- ID=$(docker run -d oracle/database11204:latest /bin/bash)
- docker export $ID > database11204.tar
- cat database11204.tar | docker import - database11204
- docker run -i -t -p 1521:1521 database11204:latest /bin/bash
- /startup.sh

### Boot2docker, MAC OSX
Probably you will run out of space
- Resize boot2docker image https://docs.docker.com/articles/b2d_volume_resize/

VirtualBox forward rules
- VBoxManage controlvm boot2docker-vm natpf1 "database,tcp,,1521,,1521"

Check the ipaddress
- boot2docker ip