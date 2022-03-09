# typed: strict
# selective-apply-code-action: refactor.extract

module Foo
  extend T::Sig

  sig {returns(String)}
  def self.greeting
         # ^^^^^^^^ apply-code-action: [A] Extract method to module
    'Hello'
  end
  
  sig do
    params(x: String)
    .returns(String)
  end
  def name(x)
    "#{Foo.greeting} #{x}"
  end
end

module A
  class B
    extend T::Sig

    sig {void}
    def bar
      m = Foo
      Foo.greeting

      m.greeting
      print((Foo if true).greeting)
    end
  end
end
Foo.greeting
