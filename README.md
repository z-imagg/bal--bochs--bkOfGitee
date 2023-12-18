# --
## [编译步骤官方文档](https://bochs.sourceforge.io/cgi-bin/topper.pl?name=New+Bochs+Documentation&url=https://bochs.sourceforge.io/doc/docbook/)
[编译步骤官方文档导引图](https://gitcode.net/crk/bochs/-/raw/master/doc/img/build_bochs.png)

## [Linux Mint 21.1 Vera下正常编译bochs](https://gitcode.net/crk/bochs/-/blob/master/bochs/build_at_Linux%20Mint%2021.1%20Vera.sh)


### 其中编译步骤抄过来如下：
```shell
#编译bochs过程:
cd /crk/bochs/bochs/
sh .conf.linux
make
```
### 用bear钩住make 以生成 compile_commands.json

> 上面编译过程的make换成```bear -- make``` 可以生成 compile_commands.json
####  bear安装 @ 'Ubuntu 23.04'
```shell
sudo apt install  bear -y
'bear 3.1.0-1'

bear --version
#bear 3.1.0
man bear
'SYNOPSIS
       bear [options] -- [build command]'

```


### vscode借助compile_commands.json成为正常C++  IDE
> 用vscode打开项目：```code /crk/bochs/bochs/ &``` ， 
1. 按住ctrl点击某个函数调用，可以跳转到该函数定义，
2. 按ctrl+alt+-, 可以返回


## 保护模式学习笔记
- [保护模式学习笔记_mathematica12](https://gitcode.net/crk/bochs/-/blob/master/%E4%BF%9D%E6%8A%A4%E6%A8%A1%E5%BC%8F%E5%AD%A6%E4%B9%A0%E7%AC%94%E8%AE%B0/%E4%BF%9D%E6%8A%A4%E6%A8%A1%E5%BC%8F_mathematica12.pdf)
- [指令的整体人类书写样式为其内存地址序升（顺序相同）;指令中的操作数的人类书写样式为其内存地址序降（顺序相反）,指令中的操作数的低高位摆放样式为其内存地址序升（顺序相同）](https://gitcode.net/crk/bochs/-/raw/dev/0/%E4%BF%9D%E6%8A%A4%E6%A8%A1%E5%BC%8F%E5%AD%A6%E4%B9%A0%E7%AC%94%E8%AE%B0/%E6%8C%87%E4%BB%A4%E7%9A%84%E6%95%B4%E4%BD%93%E4%BA%BA%E7%B1%BB%E4%B9%A6%E5%86%99%E6%A0%B7%E5%BC%8F%E4%B8%BA%E5%85%B6%E5%86%85%E5%AD%98%E5%9C%B0%E5%9D%80%E5%BA%8F%E5%8D%87%EF%BC%88%E9%A1%BA%E5%BA%8F%E7%9B%B8%E5%90%8C%EF%BC%89;%E6%8C%87%E4%BB%A4%E4%B8%AD%E7%9A%84%E6%93%8D%E4%BD%9C%E6%95%B0%E7%9A%84%E4%BA%BA%E7%B1%BB%E4%B9%A6%E5%86%99%E6%A0%B7%E5%BC%8F%E4%B8%BA%E5%85%B6%E5%86%85%E5%AD%98%E5%9C%B0%E5%9D%80%E5%BA%8F%E9%99%8D%EF%BC%88%E9%A1%BA%E5%BA%8F%E7%9B%B8%E5%8F%8D%EF%BC%89,%E6%8C%87%E4%BB%A4%E4%B8%AD%E7%9A%84%E6%93%8D%E4%BD%9C%E6%95%B0%E7%9A%84%E4%BD%8E%E9%AB%98%E4%BD%8D%E6%91%86%E6%94%BE%E6%A0%B7%E5%BC%8F%E4%B8%BA%E5%85%B6%E5%86%85%E5%AD%98%E5%9C%B0%E5%9D%80%E5%BA%8F%E5%8D%87%EF%BC%88%E9%A1%BA%E5%BA%8F%E7%9B%B8%E5%90%8C%EF%BC%89.png)  , 来自 [ \[李忠_王晓波\]_x86汇编语言-从实模式到保护模式](https://www.aliyundrive.com/drive/file/resource/653dfa43f3a3194ee96f48eda117c29bfa108a1f), 具体是 [\[李忠_王晓波\]_x86汇编语言-从实模式到保护模式-清晰-但少14章到17章-256页.pdf](https://www.aliyundrive.com/s/HkLKMVDE5WL)



# [参考书book.md](https://gitcode.net/pubz/mat-idx/-/blob/master/book.md)

## [ \[于渊\]_自己动手写操作系统 ](https://www.aliyundrive.com/drive/file/resource/653dfa447931a34610d547e78b1a60669c64ad1d)

## [ \[李忠_王晓波\]_x86汇编语言-从实模式到保护模式](https://www.aliyundrive.com/drive/file/resource/653dfa43f3a3194ee96f48eda117c29bfa108a1f)

## [ \[俞强\]_Bochs项目源码分析与注释 ](https://www.aliyundrive.com/drive/file/resource/653e025ae0c18d3401554129ad9b8293209dfb37)
