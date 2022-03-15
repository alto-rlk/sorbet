# typed: strict
# selective-apply-code-action: refactor.extract

class Inc
  extend T::Sig

  sig {params(x: Integer).returns(Integer)}
  def inc(x)
    # ^ apply-code-action: [A] Move method to a new module
    x + 1
  end
end

foo = Inc.new
res = foo.inc(42)

other_res = Inc.new.inc(42)
