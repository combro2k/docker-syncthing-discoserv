#!/bin/bash

docker run -ti --rm -p 8443 --name syncthing-discoserv combro2k/syncthing-discoserv ${@}
