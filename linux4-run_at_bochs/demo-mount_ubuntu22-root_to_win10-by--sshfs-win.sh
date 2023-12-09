#https://github.com/winfsp/sshfs-win/releases
#win10上安装 https://github.com/winfsp/sshfs-win/releases/download/v3.7.21011/sshfs-win-3.7.21011-x64.msi

# https://github.com/winfsp/winfsp/releases/tag/v2.0
#win10上安装 https://github.com/winfsp/winfsp/releases/download/v2.0/winfsp-2.0.23075.msi

#win10下执行
net use U: \\sshfs\z@u22.loc\/
net use U: /delete   #貌似没有正确卸载


#参考: https://github.com/winfsp/sshfs-win