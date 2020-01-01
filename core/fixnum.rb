##
#--
# NOTE do not define to_sym or id2name. It's been deprecated for 5 years and
# we've decided to remove it.
#++
class Fixnum < Integer
  def self.===(obj)
    Rubinius.asm do
      int = new_label
      done = new_label

      r0 = new_register
      r1 = new_register

      r_load_m_binops r0, r1

      b_if_int r1, r1, int
      r_load_false r0
      goto done

      int.set!
      r_load_true r0

      done.set!
      r_ret r0

      # TODO: teach the bytecode compiler better
      push_true
    end
  end

  # unary operators

  def !
    false
  end

  def ~
    Rubinius.asm do
      push_self

      r0 = new_register

      r_load_stack r0
      pop

      r_load_int r0, r0
      n_inot r0, r0
      r_store_int r0, r0

      r_ret r0

      # TODO: teach the bytecode compiler better
      push_true
    end
  end

  def -@
    Rubinius.asm do
      push_self

      r0 = new_register

      r_load_stack r0
      pop

      n_ineg_o r0, r0

      r_ret r0

      # TODO: teach the bytecode compiler better
      push_true
    end
  end

  # binary math operators

  def +(o)
    Rubinius.asm(o) do |o|
      add = new_label
      done = new_label

      r0 = new_register
      r1 = new_register

      r_load_m_binops r0, r1

      b_if_int r0, r1, add
      goto done

      add.set!
      n_iadd_o r0, r0, r1
      r_ret r0

      done.set!

      # TODO: teach the bytecode compiler better
      push_true
    end

    redo_coerced :+, o
  end

  def -(o)
    Rubinius.asm(o) do |o|
      sub = new_label
      done = new_label

      r0 = new_register
      r1 = new_register

      r_load_m_binops r0, r1

      b_if_int r0, r1, sub
      goto done

      sub.set!
      n_isub_o r0, r0, r1
      r_ret r0

      done.set!

      # TODO: teach the bytecode compiler better
      push_true
    end

    redo_coerced :-, o
  end

  def *(o)
    Rubinius.asm(o) do |o|
      mul = new_label
      done = new_label

      r0 = new_register
      r1 = new_register

      r_load_m_binops r0, r1

      b_if_int r0, r1, mul
      goto done

      mul.set!
      n_imul_o r0, r0, r1
      r_ret r0

      done.set!

      # TODO: teach the bytecode compiler better
      push_true
    end

    redo_coerced :*, o
  end

  # this method is aliased to / in core
  # see README-DEVELOPERS regarding safe math compiler plugin
  def divide(o)
    Rubinius.asm(o) do |o|
      div = new_label
      done = new_label

      r0 = new_register
      r1 = new_register

      r_load_m_binops r0, r1

      b_if_int r0, r1, div
      goto done

      div.set!
      n_idiv_o r0, r0, r1
      r_ret r0

      done.set!

      # TODO: teach the bytecode compiler better
      push_true
    end

    redo_coerced :/, o
  end
  alias_method :/, :divide

  def %(o)
    Rubinius.asm(o) do |o|
      div = new_label
      done = new_label

      r0 = new_register
      r1 = new_register

      r_load_m_binops r0, r1

      b_if_int r0, r1, div
      goto done

      div.set!
      n_imod_o r0, r0, r1
      r_ret r0

      done.set!

      # TODO: teach the bytecode compiler better
      push_true
    end

    redo_coerced :%, o
  end

  def divmod(other)
    Rubinius.primitive :fixnum_divmod
    redo_coerced :divmod, other
  end

  # bitwise binary operators

  def &(other)
    Rubinius.asm do
      op = new_label
      done = new_label

      r0 = new_register
      r1 = new_register

      r_load_m_binops r0, r1

      b_if_int r0, r1, op
      goto done

      op.set!
      r_load_int r0, r0
      r_load_int r1, r1

      n_iand r0, r0, r1

      r_store_int r0, r0
      r_ret r0

      done.set!

      # TODO: teach the bytecode compiler better
      push_true
    end

    other = Rubinius::Type.coerce_to_bitwise_operand other

    other & self
  end

  def |(other)
    Rubinius.asm do
      op = new_label
      done = new_label

      r0 = new_register
      r1 = new_register

      r_load_m_binops r0, r1

      b_if_int r0, r1, op
      goto done

      op.set!
      r_load_int r0, r0
      r_load_int r1, r1

      n_ior r0, r0, r1

      r_store_int r0, r0
      r_ret r0

      done.set!

      # TODO: teach the bytecode compiler better
      push_true
    end

    other = Rubinius::Type.coerce_to_bitwise_operand other

    other | self
  end

  def ^(other)
    Rubinius.asm do
      op = new_label
      done = new_label

      r0 = new_register
      r1 = new_register

      r_load_m_binops r0, r1

      b_if_int r0, r1, op
      goto done

      op.set!
      r_load_int r0, r0
      r_load_int r1, r1

      n_ixor r0, r0, r1

      r_store_int r0, r0
      r_ret r0

      done.set!

      # TODO: teach the bytecode compiler better
      push_true
    end

    other = Rubinius::Type.coerce_to_bitwise_operand other

    other ^ self
  end

  def <<(other)
    Rubinius.asm(o) do |o|
      shr = new_label
      neg = new_label
      done = new_label

      r0 = new_register
      r1 = new_register
      r2 = new_register
      r3 = new_register

      r_load_m_binops r0, r1

      b_if_int r0, r1, neg
      goto done

      neg.set!
      r_load_int r2, r1
      r_load_0 r3

      n_ige r3, r2, r3
      b_if r3, shr

      n_ineg r1, r2
      r_store_int r1, r1
      n_ishr_o r0, r0, r1
      r_ret r0

      shr.set!
      n_ishl_o r0, r0, r1
      r_ret r0

      done.set!

      # TODO: teach the bytecode compiler better
      push_true
    end

    other = Rubinius::Type.coerce_to other, Integer, :to_int

    self >> -other if other < 0

    unless other.kind_of? Fixnum
      raise RangeError, "argument is out of range for a Fixnum"
    end

    self << other
  end

  def >>(other)
    Rubinius.asm(o) do |o|
      shr = new_label
      neg = new_label
      done = new_label

      r0 = new_register
      r1 = new_register
      r2 = new_register
      r3 = new_register

      r_load_m_binops r0, r1

      b_if_int r0, r1, neg
      goto done

      neg.set!
      r_load_int r2, r1
      r_load_0 r3

      n_ige r3, r2, r3
      b_if r3, shr

      n_ineg r1, r2
      r_store_int r1, r1
      n_ishl_o r0, r0, r1
      r_ret r0

      shr.set!
      n_ishr_o r0, r0, r1
      r_ret r0

      done.set!

      # TODO: teach the bytecode compiler better
      push_true
    end

    other = Rubinius::Type.coerce_to other, Integer, :to_int

    self << -other if other < 0

    unless other.kind_of? Fixnum
      raise RangeError, "argument is out of range for a Fixnum"
    end

    self >> other
  end

  # comparison operators

  def !=(o)
    Rubinius.asm(o) do |o|
      cmp = new_label
      done = new_label

      r0 = new_register
      r1 = new_register

      r_load_m_binops r0, r1

      b_if_int r0, r1, cmp
      goto done

      cmp.set!
      n_ine r0, r0, r1

      r_load_bool r0, r0
      r_ret r0

      done.set!

      # TODO: teach the bytecode compiler better
      push_true
    end

    o != self
  end

  def ==(o)
    Rubinius.asm(o) do |o|
      cmp = new_label
      done = new_label

      r0 = new_register
      r1 = new_register

      r_load_m_binops r0, r1

      b_if_int r0, r1, cmp
      goto done

      cmp.set!
      n_ieq r0, r0, r1

      r_load_bool r0, r0
      r_ret r0

      done.set!

      # TODO: teach the bytecode compiler better
      push_true
    end

    o == self
  end

  alias_method :===, :==

  def <=>(other)
    Rubinius.primitive :fixnum_compare

    # DO NOT super to Numeric#<=>. It does not contain the coerce
    # protocol.

    begin
      b, a = math_coerce(other, :compare_error)
      return a <=> b
    rescue ArgumentError
      return nil
    end
  end

  def <(other)
    Rubinius.asm(o) do |o|
      cmp = new_label
      done = new_label

      r0 = new_register
      r1 = new_register

      r_load_m_binops r0, r1

      b_if_int r0, r1, cmp
      goto done

      cmp.set!
      n_ilt r0, r0, r1

      r_load_bool r0, r0
      r_ret r0

      done.set!

      # TODO: teach the bytecode compiler better
      push_true
    end

    b, a = math_coerce other, :compare_error
    a < b
  end

  def <=(other)
    Rubinius.asm(o) do |o|
      cmp = new_label
      done = new_label

      r0 = new_register
      r1 = new_register

      r_load_m_binops r0, r1

      b_if_int r0, r1, cmp
      goto done

      cmp.set!
      n_ile r0, r0, r1

      r_load_bool r0, r0
      r_ret r0

      done.set!

      # TODO: teach the bytecode compiler better
      push_true
    end

    b, a = math_coerce other, :compare_error
    a <= b
  end

  def >(other)
    Rubinius.asm(o) do |o|
      cmp = new_label
      done = new_label

      r0 = new_register
      r1 = new_register

      r_load_m_binops r0, r1

      b_if_int r0, r1, cmp
      goto done

      cmp.set!
      n_igt r0, r0, r1

      r_load_bool r0, r0
      r_ret r0

      done.set!

      # TODO: teach the bytecode compiler better
      push_true
    end

    b, a = math_coerce other, :compare_error
    a > b
  end

  def >=(other)
    Rubinius.asm(o) do |o|
      cmp = new_label
      done = new_label

      r0 = new_register
      r1 = new_register

      r_load_m_binops r0, r1

      b_if_int r0, r1, cmp
      goto done

      cmp.set!
      n_ige r0, r0, r1

      r_load_bool r0, r0
      r_ret r0

      done.set!

      # TODO: teach the bytecode compiler better
      push_true
    end

    b, a = math_coerce other, :compare_error
    a >= b
  end

  # predicates

  def zero?
    self == 0
  end

  # conversions

  def coerce(other)
    Rubinius.primitive :fixnum_coerce
    super other
  end

  def to_s(base=10)
    Rubinius.invoke_primitive :fixnum_to_s, self, base
  end

  # We do not alias this to #to_s in case someone overrides #to_s.
  def inspect
    Rubinius.invoke_primitive :fixnum_to_s, self, 10
  end

  def to_f
    Rubinius.primitive :fixnum_to_f
    raise PrimitiveFailure, "Fixnum#to_f primitive failed"
  end

  def size
    Rubinius.primitive :fixnum_size
    raise PrimitiveFailure, "Fixnum#size primitive failed"
  end

  def self.induced_from(obj)
    case obj
    when Fixnum
      return obj
    when Float, Bignum
      value = obj.to_i
      if value.is_a? Bignum
        raise RangeError, "Object is out of range for a Fixnum"
      else
        return value
      end
    else
      value = Rubinius::Type.coerce_to(obj, Integer, :to_int)
      return self.induced_from(value)
    end
  end

  #--
  # see README-DEVELOPERS regarding safe math compiler plugin
  #++

  alias_method :/, :divide
  alias_method :modulo, :%

  def bit_length
    Math.log2(self < 0 ? -self : self+1).ceil
  end

  def fdiv(n)
    if n.kind_of?(Fixnum)
      to_f / n
    else
      redo_coerced :fdiv, n
    end
  end

  def imaginary
    0
  end

  # Must be it's own method, so that super calls the correct method
  # on Numeric
  def div(o)
    if o.is_a?(Float) && o == 0.0
      raise ZeroDivisionError, "division by zero"
    end
    divide(o).floor
  end

  def **(o)
    Rubinius.primitive :fixnum_pow

    if o.is_a?(Float) && self < 0 && o != o.round
      return Complex.new(self, 0) ** o
    elsif o.is_a?(Integer) && o < 0
      return Rational.new(self, 1) ** o
    end

    redo_coerced :**, o
  end
end
