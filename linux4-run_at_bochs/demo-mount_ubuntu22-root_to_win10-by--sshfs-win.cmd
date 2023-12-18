@echo off
REM #https://github.com/winfsp/sshfs-win/releases
REM #win10上安装 https://github.com/winfsp/sshfs-win/releases/download/v3.7.21011/sshfs-win-3.7.21011-x64.msi

REM # https://github.com/winfsp/winfsp/releases/tag/v2.0
REM #win10上安装 https://github.com/winfsp/winfsp/releases/download/v2.0/winfsp-2.0.23075.msi

REM #win10下执行
chcp 65001
net use U: /delete   /y
rem #貌似没有正确卸载
net use U: \\sshfs\z@u22.loc\/

pause
REM #参考: https://github.com/winfsp/sshfs-win