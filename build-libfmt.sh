cd /pubx/

REPO_HOME=/pubx/fmt/
BUILD_HOME=$REPO_HOME/build

#https://github.com/fmtlib/fmt.git
git clone https://prgrmz07:sce6-C7aVvLCR_Pq6NXv@gitcode.net/pubx/fmtlib/fmt.git
cd $REPO_HOME
git checkout 10.0.0

_CXX__FLAG=" -fno-omit-frame-pointer -Wall   -O0  -fPIC "

cmake > /dev/null || sudo apt install -y cmake

rm -fr $BUILD_HOME && mkdir $BUILD_HOME && cd $BUILD_HOME
cmake \
-DFMT_TEST=OFF \
-DCMAKE_CXX_FLAGS="$_CXX__FLAG"  -DCMAKE_C_FLAGS="$_CXX__FLAG" \
-S $REPO_HOME

make -j8

ls -lh $BUILD_HOME/libfmt.a
