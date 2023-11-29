# https://dl.elv.sh/linux-386/elvish-v0.19.2.tar.gz
# https://dl.elv.sh/linux-amd64/elvish-v0.19.2.tar.gz

#lambda(匿名函数): https://elv.sh/learn/tour.html#lambdas


#语言参考: https://elv.sh/ref/language.html

#闭包: https://elv.sh/ref/language.html#closure-semantics


#支持elvish语法有关的编辑器、IDE中插件 等 链接:
#https://docs.helix-editor.com/master/lang-support.html
#https://plugins.jetbrains.com/plugin/12788-elvish-shell-language/versions
#https://marketplace.visualstudio.com/items?itemName=champii.language-elvish    #这是vscode插件?是的吧

fn ifElseIf {
    |condition1Fn act1Fn condition2Fn act2Fn|
    if $condition1Fn {
        $act1Fn
        return
    } 
    
    if $condition2Fn {
        $act2Fn
        return
    }
}

ifElseIf {} {} {} {} #语法错误
ifElseIf {;} {;} {;} {;} #语法正确, 正常执行


#效果不对: 命令 "mkdiskimage 2>/dev/null 1>/dev/null" 报错 并未导致 $false
ifElseIf { mkdiskimage 2>/dev/null 1>/dev/null }  { echo "已经安装mkdiskimage" ; }   { sudo apt install -y syslinux syslinux-common syslinux-efi syslinux-utils } { echo "mkdiskimage安装完毕(mkdiskimage由syslinux-util提供, 但是syslinux syslinux-common syslinux-efi都要安装,否则mkdiskimage产生的此 $HdImgF 几何参数不对、且 分区没格式化 )" }