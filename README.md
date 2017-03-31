Hello-HaLVM
====================
An example of a "Hello World" `HaLVM` web-server running on the `Xen` Hypervisor.

To build and run:
```shell
nix-build && sudo cp result/bin/hello-halvm . && sudo xl create hello-halvm.config -c
```