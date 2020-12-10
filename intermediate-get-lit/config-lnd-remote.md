# Connecting LiT to a standalone LND process UGH

By default LiT assumes that `lnd` is running as a standalone process locally. However
`litd` can connect to `lnd` running on a remote host.

## Quickstart

To connect Lightning Terminal to a remote LND instance first make sure your `lnd.conf`
file contains the following additional configuration settings:

```
tlsextraip=<externally-reachable-ip-address>
rpclisten=0.0.0.0:10009
```


- tls.cert
- admin.macaroon
- chainnotifier.macaroon
- invoices.macaroon
- readonly.macaroon
- router.macaroon
- signer.macaroon
- walletkit.macaroon

Create a `lit.conf` file. The default location LiT will look for the configuration file
depends on your operating system:

- MacOS: `~/Library/Application Support/Lit/lit.conf`
- Linux: `~/.lit/lit.conf`
- Windows: `~/AppData/Roaming/Lit/lit.conf`

Alternatively you can specify a different location by passing `--lit-dir=~/.lit`. After
creating `lit.conf` populate it with the following configuration settings:

```
remote.lnd.rpcserver=<externally-reachable-ip-address>:10009
remote.lnd.macaroondir=/some/folder/with/lnd/data
remote.lnd.tlscertpath=/some/folder/with/lnd/data/tls.cert
```

Run LiT:

```
./litd --uipassword=UP48lm4VjqxmOxB9X9stry6VTKBRQI
```

Visit https://localhost:8443 to access LiT.

## Additional Configuration

The "remote" mode means that `lnd` is started as a standalone process, possibly on another
host, and `litd` connects to it, right after starting its UI server. Once the connection
to the remote `lnd` node has been established, `litd` then goes ahead and starts
`faraday`, `pool` and `loop` and connects them to that `lnd` node as well.

Currently the UI server cannot connect to `loop`, `pool` or `faraday` daemons
that aren't running in the same process. But that feature will also be available
in future versions.

## Use command line parameters only

In addition to the LiT specific and remote `lnd` parameters, you must also provide
configuration to the `loop`, `pool`, and `faraday` daemons. For the remote `lnd` node, all
`remote.lnd` flags must be specified. Note that `loopd` and `faraday` will automatically
connect to the same remote `lnd` node, so you do not need to provide them with any
additional parameters unless you want to override them. If you do override them, be sure
to add the `loop.`, `pool.`, and `faraday.` prefixes.

To see all available command line options, run `litd --help`.

The most minimal example command to start `litd` and connect it to a local `lnd`
node that is running with default configuration settings is:

```shell script
$ litd --uipassword=My$trongP@ssword
```

All other command line flags are only needed to overwrite the default behavior.

Here is an example command to start `litd` connected to a testnet `lnd` that is
running on another host and overwrites a few default settings in `loop`, `pool`,
and `faraday` (optional):

```shell script
$ litd \
  --httpslisten=0.0.0.0:443 \
  --uipassword=My$trongP@ssword \
  --letsencrypt \
  --letsencrypthost=loop.merchant.com \
  --lit-dir=~/.lit \
  --remote.lit-debuglevel=debug \
  --remote.lnd.network=testnet \
  --remote.lnd.rpcserver=some-other-host:10009 \
  --remote.lnd.macaroondir=/some/folder/with/lnd/data \
  --remote.lnd.tlscertpath=/some/folder/with/lnd/data/tls.cert \
  --loop.loopoutmaxparts=5 \
  --pool.newnodesonly=true \
  --faraday.min_monitored=48h \
  --faraday.connect_bitcoin \
  --faraday.bitcoin.host=some-other-host \
  --faraday.bitcoin.user=testnetuser \
  --faraday.bitcoin.password=testnetpw
```

NOTE: Even though LiT itself only needs `lnd`'s `admin.macaroon`, the `loop`,
`pool`, and `faraday` daemons will require other macaroons and will look for
them in the folder specified with `--remote.lnd.macaroondir`. It is advised to
copy all `*.macaroon` files and the `tls.cert` file from the remote host to the
host that is running `litd`.

## Use a configuration file

You can also store the configuration in a persistent `~/.lit/lit.conf` file, so you do not
need to type in the command line arguments every time you start the server. Just remember
to use the appropriate prefixes as necessary.

Make sure you don't add any section headers (the lines starting with `[` and ending with
`]`, for example `[Application Options]`) as these don't work with the additional levels
of sub configurations. You can replace them with a comment (starting with the `#`
character) to get the same grouping effect as before.

The most minimal example of a `~/.lit/lit.conf` file that connects to a local `lnd` node
that is running with default configuration settings is:

```text
# Application Options
uipassword=My$trongP@ssword
```

All other configuration settings are only needed to overwrite the default behavior.

Here is an example `~/.lit/lit.conf` file that connects LiT to a testnet `lnd` node
running on another host and overwrites a few default settings in `loop`, `pool`,
 and `faraday` (optional):

```text
# Application Options
httpslisten=0.0.0.0:443
uipassword=My$trongP@ssword
letsencrypt=true
letsencrypthost=loop.merchant.com
lit-dir=~/.lit

# Remote options
remote.lit-debuglevel=debug

# Remote lnd options
remote.lnd.network=testnet
remote.lnd.rpcserver=some-other-host:10009
remote.lnd.macaroondir=/some/folder/with/lnd/data
remote.lnd.tlscertpath=/some/folder/with/lnd/data/tls.cert

# Loop
loop.loopoutmaxparts=5

# Pool
pool.newnodesonly=true

# Faraday
faraday.min_monitored=48h

# Faraday - bitcoin
faraday.connect_bitcoin=true
faraday.bitcoin.host=localhost
faraday.bitcoin.user=testnetuser
faraday.bitcoin.password=testnetpw
```

The default location for the `lit.conf` file will depend on your operating system:

- **On MacOS**: `~/Library/Application Support/Lit/lit.conf`
- **On Linux**: `~/.lit/lit.conf`
- **On Windows**: `~/AppData/Roaming/Lit/lit.conf`

## Example commands for interacting with the command line

Because not all functionality of `lnd` (or `loop`/`faraday` for that matter) is available
through the web UI, it will still be necessary to interact with those daemons through the
command line.

We are going through an example for each of the command line tools and will explain the
reasons for the extra flags. The examples assume that LiT is started with the following
configuration (only relevant parts shown here):

```text
httpslisten=0.0.0.0:443
lit-dir=~/.lit

remote.lnd.network=testnet
remote.lnd.rpcserver=some-other-host:10009
remote.lnd.macaroondir=/some/folder/with/lnd/data
remote.lnd.tlscertpath=/some/folder/with/lnd/data/tls.cert
```

Because in the remote `lnd` mode all other LiT components (`loop`, `pool`,
`faraday` and the UI server) listen on the same port (`443` in this example) and
use the same TLS certificate (`~/.lit/tls.cert` in this example), some command
line calls now need some extra options that weren't necessary before.

**NOTE**: All mentioned command line tools have the following behavior in common: You
either specify the `--network` flag and the `--tlscertpath` and `--macaroonpath` are
implied by looking inside the default directories for that network. Or you specify the
`--tlscertpath` and `--macaroonpath` flags explicitly, then you **must not** set the
`--network` flag. Otherwise, you will get an error like
`[lncli] could not load global options: unable to read macaroon path (check the network setting!): open /home/<user>/.lnd/data/chain/bitcoin/testnet/admin.macaroon: no such file or directory`.

### Example `lncli` command

The `lncli` commands in the "remote" mode are the same as if `lnd` was running standalone
on a remote host. We need to specify all flags explicitly.

```shell script
$ lncli --rpcserver=some-other-host:10009 \
  --tlscertpath=/some/folder/with/lnd/data/tls.cert \
  --macaroonpath=/some/folder/with/lnd/data/admin.macaroon \
  getinfo
```

### Example `loop` command

This is where things get a bit tricky. Because as mentioned above, `loopd` also runs on
the same port as the UI server. That's why we have to both specify the `host:port` as well
as the TLS certificate of LiT. But `loopd` verifies its own macaroon, so we have to
specify that one from the `.loop` directory.

```shell script
$ loop --rpcserver=localhost:443 --tlscertpath=~/.lit/tls.cert \
  --macaroonpath=~/.loop/testnet/loop.macaroon \
  quote out 500000
```

You can easily create an alias for this by adding the following line to your `~/.bashrc`
file:

```shell script
alias lit-loop="loop --rpcserver=localhost:443 --tlscertpath=~/.lit/tls.cert --macaroonpath=~/.loop/testnet/loop.macaroon"
```

### Example `pool` command

Again, `poold` also runs on the same port as the UI server and we have to
specify the `host:port` and the TLS certificate of LiT but use the macaroon from
the `.pool` directory.

```shell script
$ pool --rpcserver=localhost:443 --tlscertpath=~/.lit/tls.cert \
  --macaroonpath=~/.pool/testnet/pool.macaroon \
  accounts list
```

You can easily create an alias for this by adding the following line to your
`~/.bashrc` file:

```shell script
alias lit-pool="pool --rpcserver=localhost:443 --tlscertpath=~/.lit/tls.cert --macaroonpath=~/.pool/testnet/pool.macaroon"
```

### Example `frcli` command

Faraday's command line tool follows the same pattern as loop. We also have to specify the
server and TLS flags for `lnd` but use `faraday`'s macaroon:

```shell script
$ frcli --rpcserver=localhost:443 --tlscertpath=~/.lit/tls.cert \
  --macaroonpath=~/.faraday/testnet/faraday.macaroon \
  audit
```

You can easily create an alias for this by adding the following line to your `~/.bashrc`
file:

```shell script
alias lit-frcli="frcli --rpcserver=localhost:443 --tlscertpath=~/.lit/tls.cert --macaroonpath=~/.faraday/testnet/faraday.macaroon"
```
