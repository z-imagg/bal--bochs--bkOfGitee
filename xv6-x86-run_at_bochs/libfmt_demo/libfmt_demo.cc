#include <fmt/core.h>
#include <string>

int main(){
std::string json_text=fmt::format(
  "{\"selector_value\":\"0x{:X}\", \"selector_index\":\"0x{:X}\", \"selector_ti\":\"0x{:X}\", \"selector_rpl\":\"0x{:X}\"}", 
  22,
  343,
  44,
  55
  );

  return 0;
}