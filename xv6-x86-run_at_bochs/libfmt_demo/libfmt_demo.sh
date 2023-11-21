g++ -I/pubx/fmt/include/ -g -O0 -ggdb -c libfmt_demo.cc
g++ -o demo libfmt_demo.o /pubx/fmt/build/libfmt.a
./demo 
# terminate called after throwing an instance of 'fmt::v10::format_error'
#   what():  invalid format string
# 已放弃 (核心已转储)
