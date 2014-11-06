require "test_helper"

class Test < Minitest::Test
  def test_callbacks
    actions = []
    klass = Class.new do
      include Fetch::Callbacks
      define_callback :before, :after
      before { actions << "something before" }
      after { actions << "something after" }
      def do_something
        before
        after
      end
    end
    klass.new.do_something
    assert_equal ["something before", "something after"], actions
  end

  def test_all_callbacks_are_run
    actions = []
    klass = Class.new do
      include Fetch::Callbacks
      define_callback :before
      before { actions << "first" }
      before { actions << "second" }
      def do_something
        before
      end
    end
    klass.new.do_something
    assert_equal ["first", "second"], actions
  end

  def test_value_from_last_callback_is_returned
    klass = Class.new do
      include Fetch::Callbacks
      define_callback :before
      before { "first" }
      before { "second" }
    end
    assert_equal "second", klass.new.before
  end

  def test_callbacks_take_optional_arguments
    actions = []
    klass = Class.new do
      include Fetch::Callbacks
      define_callback :before, :after
      before { |some_arg| actions << "one: #{some_arg}" }
      after { |some_arg| actions << "two: #{some_arg.inspect}" }
      def do_something
        before("first")
        after
      end
    end
    klass.new.do_something
    assert_equal ["one: first", "two: nil"], actions
  end

  def test_callbacks_are_inherited
    before1 = Proc.new {}
    before2 = Proc.new {}
    superclass = Class.new do
      include Fetch::Callbacks
      define_callback :before
      before(&before1)
      before(&before2)
    end
    subclass = Class.new(superclass)
    assert_equal [before1, before2], subclass.callbacks[:before]
  end

  def test_callbacks_are_not_added_to_superclass
    before1, before2, before3 = 3.times.map { Proc.new {} }
    superclass = Class.new do
      include Fetch::Callbacks
      define_callback :before
      before(&before1)
      before(&before2)
    end
    subclass = Class.new(superclass) do
      before(&before3)
    end
    assert_equal [before1, before2], superclass.callbacks[:before]
    assert_equal [before1, before2, before3], subclass.callbacks[:before]
  end

  def test_callbacks_can_take_fixed_values
    klass = Class.new do
      include Fetch::Callbacks
      define_callback :modules
      modules "one", "two", "three"
    end
    assert_equal ["one", "two", "three"], klass.new.modules
  end
end