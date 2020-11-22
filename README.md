# android_extract_kernel

```sh
imjtool.ELF64 /path/boot.img extract

strings extracted/kernel | grep "Linux version"

./fka64 extracted/kernel vmlinux

ida pro -> loader/vmlinux.py
```