g++ -I/pubx/fmt/include/ -g -O0 -ggdb -c libfmt_demo.cc
g++ -o demo libfmt_demo.o /pubx/fmt/build/libfmt.a
./demo 
# {"selector_value":"0x16", "selector_index":"0x157", "selector_ti":"0x2C", "selector_rpl":"0x37"}