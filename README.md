# anvil impersonate helper

- lightweight script to fork any evm-based blockchain with `anvil`
- forward local node to a public https endpoint with `devtunnel`
- impersonate any account with `anvil`
- simulate batch tx with `cast` (wip)

### requirements

- unix-like os
- [devtunnel cli](https://learn.microsoft.com/en-us/azure/developer/dev-tunnels/)
- [cast](https://book.getfoundry.sh/cast/)
- [anvil](https://book.getfoundry.sh/anvil/)

### use

```
$ chmod 755 server.sh
$ export PORT=<port>
$ export ENDPOINT=<endpoint>
$ export IMP_ADDR=<addr>
$ ./server.sh -f $ENDPOINT -a $IMP_ADDR [-p $PORT]
```

### example

```
$ ./server.sh -f https://eth.llamarpc.com -a <impersonate_address> -p 8080
>
Start forking network using anvil...
[anvil]
fork-url: https://eth.llamarpc.com
port: 8080
impersonate_account: <addr>
Anvil is running with PID <pid>
forked https://eth.llamarpc.com, listening on 127.0.0.1:8080 in background...

[devtunnel]
forwarded 127.0.0.1:8080 to https://<TUNNEL_ID>.asse.devtunnels.ms

[anvil]
impersonating account: <addr>
```
