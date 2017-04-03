Hello-HaLVM
====================
An example of a "Hello World" `HaLVM` web-server running on the `Xen` Hypervisor.

To build and run:
```shell
nix-build && ./result/bin/deployKernel
# `deployKernel` is simply defined as:
# sudo xl create /nix/store/1qf0whzlnykffgcg65wazddnz0b1gjvc-xenConfig -c
```

Result:
```
$ ./result/bin/deployKernel
Parsing config from /nix/store/rczkj3ab11799nwr0kqq8jn7zarjc2mq-xenConfig
Assigned IP: (10,0,1,183)
C-[
$ curl 10.0.1.183
<!doctype html><html><head></head><body>HaLVM says Hello! You are request 0</body></html>%
```

To setup `tap` device
```shell
nix-build && result/bin/setupTap.sh
```

To develop with linux `tap` device
```shell
nix-shell
```

To develop with `halvm-ghc`
```shell
nix-shell halvm-shell.nix
```
