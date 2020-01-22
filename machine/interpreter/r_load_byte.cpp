#include "instructions/r_load_byte.hpp"

namespace rubinius {
  namespace interpreter {
    intptr_t r_load_byte(STATE, CallFrame* call_frame, intptr_t const opcodes[]) {
      instructions::r_load_byte(call_frame, argument(0), argument(1), argument(2));

      call_frame->next_ip(instructions::data_r_load_byte.width);

      return ((instructions::Instruction)opcodes[call_frame->ip()])(state, call_frame, opcodes);
    }
  }
}
