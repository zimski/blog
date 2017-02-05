---
title: "SSH tunneling TCP & UDP"
layout: post
date: 2017-01-25 22:48
image: /assets/images/ssh_tunnel_1.jpg
headerImage: false
tag:
- system
- networking
- linux
blog: true
author: zimski
description: Creating Tunnels to go any where !
---

# SSH tunneling
Today we will explore a very use-full feature of SSH ... *Tunneling*

As a developer or as an Ops, sometimes you need to access to a specific
port on a specific server but this port is protected behind a firewall, by the way you have already access to this server by SSH, it's not a HACKING blog post ;)

To remove this obstacle you need to setup a SSH tunnel.

# How it's work
![TCP ssh tunneling](/assets/images/ssh_tunnel_1.png){:class="img-responsive"}

Basically, the SSH tunnel will use your SSH connection to forward packets from your chosen local port to the targeted port on the remote host.

# Let's do it
```sh
ssh -L 1111:TARGET_HOSTNAME:2000 TARGET_SERVER
```

The main difference between `TARGET_HOSTNAME` and `TARGET_SERVER` is where your service is listing.
Imagine your target service is listening on `localhost` interface, so your command need to be:

```sh
ssh -L 1111:localhost:2000 TARGET_SERVER
```

If the service is listening on a specific interface, you should replace `TARGET_HOSTNAME` by the right value
If you don't know, check in the config file of the service and look for a `listen`


You can now do what ever you want with `1111` port, if a target service is a `HTTP` browser so you can open your browser and access to your remote service by entering this URL `http://localhost:1111`.

# UDP tunnel
In the previous part, we have seen the TCP tunneling, if you want to do one over `UDP` you can do it by using a powerfull command called `socat`

![UDP ssh tunneling](/assets/images/ssh_tunnel_2.png){:class="img-responsive"}

Okay, now it's a little bit more complicated but stay with me, you will see that's really simple if you understand the different parts

In the remote host, we have a server listening on `3000 UDP port` and my goal is to send him some `UDP` packets from my host.

I can't use the only the ssh tunneling because it doesn't support the UDP trafic, and my hero is `socat` will save me.

We will tell to socat to:

### In My laptop
We will use `socat` to create a Little server listening on `UDP` packets on the 3000 port, when socat receive udp packets, it will encapsulate theme in `TCP` packets and send them to 1111 port.

The ssh tunnel listening on this port will transport my packets to the the my target server.

```sh
socat -T15 udp4-recvfrom:3000,reuseaddr,fork tcp:localhost:1111
```

### In my target server
`socat` is listening to `TCP` packets from 2000 port and will transform them to an `UDP` packet and send them to my service ... ouah

```sh
socat -U tcp4-listen:2000,reuseaddr,fork UDP:localhost:3000
# the -U will tell to socat to do not try listening on 3000 udp port, we have already our service listening to
```

In my example is a uni-directional communications between my laptop and my server.

I have used the same configuration when I was facing the need to send `Bstats` metrics from
my app running on my host to a remote server where they are a collector of Bstats metrics installed.

If you want a full duplex communications, just remove the `-U` in the socat command.
