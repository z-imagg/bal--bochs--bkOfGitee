# https://dl.elv.sh/linux-386/elvish-v0.19.2.tar.gz
# https://dl.elv.sh/linux-amd64/elvish-v0.19.2.tar.gz

# https://elv.sh/learn/tour.html#lambdas

# https://elv.sh/ref/language.html

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
