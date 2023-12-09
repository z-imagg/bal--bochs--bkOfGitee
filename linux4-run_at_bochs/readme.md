
# 各主机访问端口备忘
- w10.loc(win10Ssh)/ubuntu23x64:       10.0.4.23:22; (TPLINK_*),23就是指ubuntu23
- ubuntu14x32:                         10.0.4.14:22; (TPLINK_*),14就是指ubuntu14
- u22.loc/ubuntu22x64:                 10.0.4.22:22; (TPLINK_*),22就是指ubuntu22
>>>>>> 主机ubuntu22x64Loc 运行本目录内的脚本
 

# 步骤
> 在 主机ubuntu22x64Loc上运行 脚本bochs2.7boot-grub4dos-linux4.14.259.sh
>  脚本bochs2.7boot-grub4dos-linux4.14.259.sh 会 调用 内核编译脚本build-linux4.14.259-on-x64_u22.04.3LTS.sh

# Linux-Run_At_Bochs 
Linux_Run_At_Bochs所用Linux的GIT仓库分支:linux-4.14.y

>

Linux_Run_At_Bochs所用Linux的GIT仓库CommitId:ae1952ac1aac66010a51a69c4592d72724d91ce2

gcc拦截器修改后的linux-kernel的linux-4.14.y-dev分支：https://gitcode.net/crk/linux-stable/-/commits/linux-4.14.y-dev

gcc拦截器修改后的linux-kernel的单次提交:  https://gitcode.net/crk/linux-stable/-/commit/91ce0145f5a3d643ee2018e57309300935229e01