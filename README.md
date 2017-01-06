# dprive-nginx-bind

## DPRIVE Container


This Docker container implements a [DPRIVE](https://datatracker.ietf.org/wg/dprive/documents/) [RFC 7858](https://datatracker.ietf.org/doc/rfc7858/) server by running [NGINX](nginx.org) as a TLS proxy in front of [ISC BIND](https://www.isc.org/downloads/bind/).

It listens on both the official DPRIVE port (853), and also on port 443 (as a test / proof-of-concept). 

The container builds on both Ubuntu 16.04 and OS X Sierra, and have been tested deployed on Ubuntu, Amazon AWS EC2 Container Service and [Google Container Engine (GKE)](https://cloud.google.com/container-engine/). The `gke` direcotry contains the YAML files I use to start this on GKE.

The `stubby_configs` directory contains configurations for using this with [getdns](http://getdnsapi.net/) [Stubby](https://portal.sinodun.com/wiki/display/TDNS/DNS+Privacy+daemon+-+Stubby).

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
##### Docker
Start:

    docker-compose up  -d
    
Stop:
    
    docker-compose kill
    
Attach to container:

	docker exec -it compose_dprive-nginx-bind_1 bash
	
##### Google Container Engine
Starting deploymment and service:

```
$ kubectl create -f dprive-nginx-bind-deployment.yaml
$ kubectl create -f dprive-nginx-bind-service.yaml
```

Checking:

```
$ kubectl get deployment dprive-nginx-bind
NAME                DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
dprive-nginx-bind   1         1         1            1           3d
$ kubectl get service dprive-nginx-bind
NAME                CLUSTER-IP     EXTERNAL-IP       PORT(S)           AGE
dprive-nginx-bind   10.3.242.209   104.196.153.172   853/TCP,443/TCP   8m
```

Stopping:

```
$ kubectl delete service dprive-nginx-bind-service
$ kubectl delete deployment dprive-nginx-bind-deployment
```

#### Client
Included in `stubby-snozzages.conf` is a [Stubby] (https://portal.sinodun.com/wiki/display/TDNS/DNS+Privacy+daemon+-+Stubby) config file to talk to a test container which I'm running. Generating the `tls_pubkey_pinset` is a little tricky. Here is the cheat:

	openssl x509 -noout -in wildcard_snozzages.com.crt  -pubkey | openssl asn1parse -noout -inform pem -out public.key
	openssl dgst -sha256 -hex public.key | awk -F '= ' '{print "0x"$2}' 
  
  
##### Example:

Client (I add `nameserver 127.0.0.1` to `/etc/resolv.conf`)

```
$ sudo ./bin/stubby -C ./etc/stubby-gce.conf
[02:58:20.629838] => ENTRY:        _getdns_submit_stub_request        : MSG: 0x7fd32e802008 TYPE: 1
[02:58:20.631413] --- SETUP:       upstream_select_stateful           : Testing upstreams  0 0
[02:58:20.631421] --- SETUP:       upstream_select_stateful           : Testing upstreams  1 0
[02:58:20.631434] --- SETUP:       upstream_connect                   : Getting upstream connection:  0x7fd32d0119c8
[02:58:20.631439] --- SETUP:       tcp_connect                        : Creating TCP connection:      0x7fd32d0119c8
[02:58:20.631753] --- SETUP(TLS):  tls_create_object                  : Hostname verification requested for: *.snozzages.com
[02:58:20.631793] --- SETUP(TLS):  tls_create_object                  : Using Strict TLS
[02:58:20.631803] GETDNS_DAEMON:   104.196.153.172 : Conn init     : Transport=TLS - Profile=Strict
[02:58:20.631808] --- SETUP:       upstream_find_for_transport        : FD:  8 Connecting to upstream: 0x7fd32d0119c8   No: 1
[02:58:20.631817] ----- SCHEDULE:  upstream_schedule_netreq           : MSG: 0x7fd32e802008 (schedule event)
[02:58:20.631920] => ENTRY:        _getdns_submit_stub_request        : MSG: 0x7fd32d802808 TYPE: 28
[02:58:20.631932] --- SETUP:       upstream_connect                   : Getting upstream connection:  0x7fd32d0119c8
[02:58:20.631938] --- SETUP:       upstream_find_for_transport        : FD:  8 Connecting to upstream: 0x7fd32d0119c8   No: 1
[02:58:20.631943] ----- SCHEDULE:  upstream_schedule_netreq           : MSG: 0x7fd32d802808 (schedule event)
[02:58:20.631950] ------- WRITE:   upstream_write_cb                  : MSG: 0x7fd32e802008 (writing)
[02:58:20.631973] --- SETUP(TLS):  tls_do_handshake                   : FD:  8
[02:58:20.696750] ------- READ:    upstream_read_cb                   : FD:  8
[02:58:20.696801] --- SETUP(TLS):  tls_do_handshake                   : FD:  8
[02:58:20.697742] --- SETUP(TLS):  tls_verify_callback                : FD:  8 Verify result: (0) "ok"
[02:58:20.697785] --- SETUP(TLS):  _getdns_verify_pinset_match        : Name of cert: 0  CN = *.snozzages.com
[02:58:20.697892] --- SETUP(TLS):  _getdns_verify_pinset_match        : Pubkey 0 matched pin 0x7fd32cc01780 (32)
[02:58:20.698246] --- SETUP(TLS):  tls_verify_callback                : FD:  8 Verify result: (0) "ok"
[02:58:20.698267] --- SETUP(TLS):  _getdns_verify_pinset_match        : Name of cert: 0  CN = *.snozzages.com
[02:58:20.698355] --- SETUP(TLS):  _getdns_verify_pinset_match        : Pubkey 0 matched pin 0x7fd32cc01780 (32)
[02:58:20.698846] --- SETUP(TLS):  tls_verify_callback                : FD:  8 Verify result: (0) "ok"
[02:58:20.698868] --- SETUP(TLS):  _getdns_verify_pinset_match        : Name of cert: 0  CN = *.snozzages.com
[02:58:20.698934] --- SETUP(TLS):  _getdns_verify_pinset_match        : Pubkey 0 matched pin 0x7fd32cc01780 (32)
[02:58:20.732940] ------- READ:    upstream_read_cb                   : FD:  8
[02:58:20.732994] --- SETUP(TLS):  tls_do_handshake                   : FD:  8
[02:58:20.733630] --- SETUP(TLS):  tls_do_handshake                   : FD:  8 Handshake succeeded with auth state 2. Session is new.
[02:58:20.733694] ------- WRITE:   upstream_write_cb                  : MSG: 0x7fd32e802008 (writing)
[02:58:20.733711] --- SETUP:       stub_tls_write                     : FD:  8 Requesting keepalive
[02:58:20.734099] ------- WRITE:   upstream_write_cb                  : MSG: 0x7fd32d802808 (writing)
[02:58:20.774853] ------- READ:    upstream_read_cb                   : FD:  8
[02:58:20.774915] ------- READ:    upstream_read_cb                   : MSG: 0x7fd32e802008 (read)
[02:58:20.774940] ------- READ:    match_edns_opt_rr                  : OPT RR: ; EDNS: version: 0; flags: ; udp: 4096
[02:58:20.774948] --- CLEANUP:     stub_cleanup                       : MSG: 0x7fd32e802008
[02:58:20.774956] ----- SCHEDULE:  upstream_reschedule_events         : FD:  8
[02:58:20.832630] ------- READ:    upstream_read_cb                   : FD:  8
[02:58:20.832757] ------- READ:    upstream_read_cb                   : MSG: 0x7fd32d802808 (read)
[02:58:20.832782] ------- READ:    match_edns_opt_rr                  : OPT RR: ; EDNS: version: 0; flags: ; udp: 4096
[02:58:20.832793] --- CLEANUP:     stub_cleanup                       : MSG: 0x7fd32d802808
[02:58:20.832804] ----- SCHEDULE:  upstream_reschedule_events         : FD:  8
[02:58:20.832836] ----- SCHEDULE:  upstream_reschedule_events         : FD:  8 Connection idle - timeout is 10000
[02:58:24.751765] => ENTRY:        _getdns_submit_stub_request        : MSG: 0x7fd32e008e08 TYPE: 1
[02:58:24.751795] --- SETUP:       upstream_connect                   : Getting upstream connection:  0x7fd32d0119c8
[02:58:24.751802] --- SETUP:       upstream_find_for_transport        : FD:  8 Connecting to upstream: 0x7fd32d0119c8   No: 1
[02:58:24.751808] ----- SCHEDULE:  upstream_schedule_netreq           : MSG: 0x7fd32e008e08 (schedule event)
[02:58:24.751829] ------- WRITE:   upstream_write_cb                  : MSG: 0x7fd32e008e08 (writing)
[02:58:24.797597] ------- READ:    upstream_read_cb                   : FD:  8
[02:58:24.797682] ------- READ:    upstream_read_cb                   : MSG: 0x7fd32e008e08 (read)
[02:58:24.797696] ------- READ:    match_edns_opt_rr                  : OPT RR: ; EDNS: version: 0; flags: ; udp: 4096
[02:58:24.797703] --- CLEANUP:     stub_cleanup                       : MSG: 0x7fd32e008e08
[02:58:24.797709] ----- SCHEDULE:  upstream_reschedule_events         : FD:  8
[02:58:24.797715] ----- SCHEDULE:  upstream_reschedule_events         : FD:  8 Connection idle - timeout is 10000
[02:58:34.798471] --- CLEANUP:     upstream_idle_timeout_cb           : FD:  8 Closing connection
[02:58:34.798524] GETDNS_DAEMON:   104.196.153.172 : Conn closed   : Transport=TLS - Resp=3,Timeouts=0,Auth=Success,Keepalive(ms)=10000
[02:58:34.798539] GETDNS_DAEMON:   104.196.153.172 : Upstream stats: Transport=TLS - Resp=3,Timeouts=0,Best_auth=Success
[02:58:34.798552] GETDNS_DAEMON:   104.196.153.172 : Upstream stats: Transport=TLS - Conns=1,Conn_fails=0,Conn_shutdowns=0,Backoffs=0
```
  
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


