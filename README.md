# quakelive-docker
Docker container that automatically creates a Quake Live server with [minqlxtended](https://github.com/tjone270/minqlxtended).


## Setup
Take a look at the volumes in `docker-compose.yml` for interesting files to create/edit. The main ones you will want to touch are `server.cfg`, `extra-plugins` and the `workshop` folder inside of the `server-config` directory.

When you're done, just build the container and run it:

```
docker compose build
docker compose up -d
```

Afterwards, you should be able to connect to the server using the hosts IP (default ql port 27960 is used, you can change this in `docker-compose.yml`). Make sure the firewall allows incoming connections to the port you are using, both TCP and UDP.
