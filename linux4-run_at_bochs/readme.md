
# 各主机访问端口备忘
- w10.loc(win10Ssh)/ubuntu23x64:       10.0.4.23:22; (TPLINK_*),23就是指ubuntu23
- ubuntu14x32:                         10.0.4.14:22; (TPLINK_*),14就是指ubuntu14
- u22.loc/ubuntu22x64:                 10.0.4.22:22; (TPLINK_*),22就是指ubuntu22
>>>>>> 主机ubuntu22x64Loc 运行本目录内的脚本
 

# 步骤
> 在 主机ubuntu22x64Loc上运行 脚本bochs2.7boot-grub4dos-linux4.14.259.sh
>  脚本bochs2.7boot-grub4dos-linux4.14.259.sh 会 调用 内核编译脚本build-linux4.14.259-on-x64_u22.04.3LTS.sh

# Linux-Run_At_Bochs 
Linux_Run_At_Bochs对linux-stable分支: https://gitcode.net/crk/linux-stable/-/commits/linux-4.14.y , https://gitcode.net/crk/linux-stable/-/commit/ae1952ac1aac66010a51a69c4592d72724d91ce2
用interceptor.py拦截gcc命令, 
 将gcc命令中选项-O2替换为选项-O1, 
 运行 clang插件 funcIdAsm 以 在 函数开头 插入 funcIdAsm 后,
 再运行gcc命令以编译改后源码

改后源码的linux-stable分支: https://gitcode.net/crk/linux-stable/-/commits/linux-4.14.y-dev-O2-to-O1-bochs2.7-busyboxi686-run-to-shell-ok , https://gitcode.net/crk/linux-stable/-/commit/7618f6ab872bbadf5cc775233d703075cbaa8c60