
#git忽略文件模式变化（即rwx等）
git config --global --unset-all core.filemode
git config --unset-all core.filemode
git config core.filemode false
# git config --global  core.filemode false