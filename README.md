Hello-HaLVM
====================
An example of a "Hello World" `HaLVM` web-server running on the `Xen` Hypervisor.

To build and run:
```shell
nix-build && ./result/bin/deployKernel
# `deployKernel` is simply defined as:
# sudo xl create /nix/store/1qf0whzlnykffgcg65wazddnz0b1gjvc-xenConfig -c
```

To setup `tap` device
```shell
nix-build && result/bin/setupTap.sh
```

To develop with linux `tap` device
```shell
nix-shell
```

To develop with halvm-ghc
```shell
nix-shell halvm-shell.nix
```
