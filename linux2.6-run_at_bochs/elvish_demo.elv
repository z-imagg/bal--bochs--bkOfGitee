# https://dl.elv.sh/linux-386/elvish-v0.19.2.tar.gz
# https://dl.elv.sh/linux-amd64/elvish-v0.19.2.tar.gz

# https://elv.sh/learn/tour.html#lambdas

#支持elvish语法有关的编辑器、IDE中插件 等 链接:
#https://docs.helix-editor.com/master/lang-support.html
#https://plugins.jetbrains.com/plugin/12788-elvish-shell-language/versions
#https://marketplace.visualstudio.com/items?itemName=champii.language-elvish    #这是vscode插件?是的吧


if (eq (uname) Linux) { echo "You're on Linux" }


if ($true) {
    echo "tt"
} else if ($false) { #错
    echo "ff"
}

#对
if $true {
    echo "tt"
} else {
    echo "ff"
}


if $true {
    echo "tt"
} else if $true {#错
    echo "ff"
}