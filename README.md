# dprive-nginx-bind

## DPRIVE Container


This Docker container implements a [DPRIVE](https://datatracker.ietf.org/wg/dprive/documents/) [RFC 7858](https://datatracker.ietf.org/doc/rfc7858/) server by running [NGINX](nginx.org) as a TLS proxy in front of [ISC BIND](https://www.isc.org/downloads/bind/).

It listens on both the official DPRIVE port (853), and also on port 443 (as a test / proof-of-concept). 

The container builds on both Ubuntu 16.04 and OS X Sierra, and deploys on Ubuntu, Google 

### Known issues / limitations
This Dockerfile is based on Ubuntu and uses the Ubuntu BIND and NGINX packages. When I have more time, I'm planning on making new images which builds BIND and NGINX instead of using the packages.



### Installation

1. Install [Docker](https://www.docker.com/).
2. Run `make`
3. Edit `docker-compose.yml` and update to your IP addresses
4. Start container: `docker-compose up dprive-nginx-bind -d`

#### Customization

1. The `Makefile` copies the contents of `./files/config/` to `DOCKER_DATA` (/tank/data/docker on my machines). I have removed the `wildcard_snozzages.com.key`, `rnfc.conf` and `rndc.key` files from the repo.
2. Replace the IP address in `docker-compose.yml` with your IP (or remove the IP if you don't bind to a specific IP), update the `/tank/data/docker/dprive-nginx-bind` directory to wherever you mount Docker volumes.


#### Usage

Start:

    docker-compose up  -d
    
Stop:
    
    docker-compose kill
    
Attach to container:

	docker exec -it compose_dprive-nginx-bind_1 bash

#### Client
Included in `stubby-snozzages.conf` is a [Stubby] (https://portal.sinodun.com/wiki/display/TDNS/DNS+Privacy+daemon+-+Stubby) config file to talk to a test container which I'm running. Generating the `tls_pubkey_pinset` is a little tricky. Here is the cheat:

	openssl x509 -noout -in wildcard_snozzages.com.crt  -pubkey | openssl asn1parse -noout -inform pem -out public.key
	openssl dgst -sha256 -hex public.key | awk -F '= ' '{print "0x"$2}' 
  
  
  
#### Release notes / changelog
V0.2.0:

* Moar containerized
* Self-contained for Google Container Engine / Amazon ECS
  * No longer exposes volumes, makefile much simpler


V0.1.0: Initial Release

* Docker container which puts NGINX (as a TLS Proxy) in front of BIND
* Uses NGINX and ISC BIND packages
* Listens on both TCP 853 (domain-s) and 433 (https)
* Exports statistics and similar to volumes


  
#### Credits
This is largely based on the [Sinodun](https://www.sinodun.com/) [Using a TLS proxy] (https://portal.sinodun.com/wiki/display/TDNS/Using+a+TLS+proxy) config, converted to be a container. 


