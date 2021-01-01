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