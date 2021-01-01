# android 提取内核指南

@(盘古石)[kernel, android]


## 获得对应的 boot.img

### 拥有 root 权限的情况
Android 内核文件存放在`boot`分区，先在设备中找到`boot`分区存放的位置：
```bash
cd /dev/block/platform/msm_xxx/by-name/
ls -l boot
```

这个`boot`文件是个软链接，指向对应的`/dev/block/xxx` 即是`boot`分区数据。
用`dd`将其`dump`出来：
```bash
dd if=/dev/block/xxx of=/sdcard/boot.img
```

### 官方网站下载对应的 ROM
小米的`ROM`包都是`.zip`格式，可以轻松解包，得到内含的`boot.img`。从[此处](https://xiaomirom.com/series/)获得小米 ROM 下载链接。

OPPO 的`ROM`包是`.ozip`格式，无法直接解包，它是由`.zip`格式压缩后再通过 OPPO 自己的设计的密钥算法进行加密形成的`.ozip`格式包。可以自己通过反编译`recovery`文件来得到密钥。从[此处](https://github.com/bkerler/oppo_ozip_decrypt)获得`python3`脚本可以转换`.ozip`成`.zip`文件。

得到`.zip`包后可以解压出`boot.img`文件。


### 提取内核镜像文件
使用`imgtool`工具分离`boot.img`文件，一般有`kernel`、`kernelimage`、 `ramdisk`等相关文件。分离工具从[此处](http://newandroidbook.com/tools/imgtool.html)获得。
```bash
    imjtool.ELF64 /PATH/boot.img extract
```

此时，需要确定其中有效的内核镜像，针对`kernel`、`kernelimage`使用命令检查是否有输出。
```bash
strings xxx | grep "Linux version "
```

当然，也有可能该文件是`.gzip`压缩文件，需要解压缩。


### 内核镜像反随机化

查看是64位或者是32位的内核镜像后，使用不同的程序进行去随机化，从[此处](https://github.com/nforest/droidimg)获得资源。
```bash
例如：
./fka64 extracted/kernel vmlinux
```

ps. 若无法去除随机化，可能是内核镜像本身有多余的数据，导致无法识别。
```bash
dd if=kernel of=kernel2 bs=1 skip=xxx 
```

### 获得内核数据 
最后，使用`ida pro`打开`vmlinux`文件，同时`ida pro`的`loader`文件夹里放入`vmlinux.py`该脚本可以解析`kallsyms`符号表。


### 自动化脚本

需要一个参数， `boot.img`所在目录的绝对路径

```bash
# !/bin/sh

if [ ! -n "$1" ];then
    echo "you need input PATH !"
    exit 1
fi

rm -r extracted/
./imjtool.ELF64 $1boot.img  extract

check_result1=`strings extracted/kernel | grep "Linux version "`
check_result2=`strings extracted/kernelimage | grep "Linux version"`


if [ -n "$check_result1" ];then
    ./fka64 extracted/kernel $1vmlinux
elif [ -n "$check_result2" ];then
    ./fka64 extracted/kernelimage $1vmlinux
else
    echo "kernel wrong"
    exit 3
fi
exit 0
```
