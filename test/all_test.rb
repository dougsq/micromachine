require 'test/unit'
require 'rubygems'
require 'contest'

require File.dirname(__FILE__) + "/../lib/micromachine"

class MicroMachineTest < Test::Unit::TestCase
  context "basic interaction" do
    setup do
      @machine = MicroMachine.new(:pending)
      @machine.transitions_for[:confirm]  = { :pending => :confirmed }
      @machine.transitions_for[:ignore]   = { :pending => :ignored }
      @machine.transitions_for[:reset]    = { :confirmed => :pending, :ignored => :pending }
    end

    should "have an initial state" do
      assert_equal :pending, @machine.state
    end

    should "discern transitions" do
      assert @machine.trigger(:confirm)
      assert_equal :confirmed, @machine.state

      assert !@machine.trigger(:ignore)
      assert_equal :confirmed, @machine.state

      assert @machine.trigger(:reset)
      assert_equal :pending, @machine.state

      assert @machine.trigger(:ignore)
      assert_equal :ignored, @machine.state
    end
  end

  context "dealing with callbacks" do
    setup do
      @machine = MicroMachine.new(:pending)
      @machine.transitions_for[:confirm]  = { :pending => :confirmed }
      @machine.transitions_for[:ignore]   = { :pending => :ignored }
      @machine.transitions_for[:reset]    = { :confirmed => :pending, :ignored => :pending }

      @machine.on(:pending)   { @state = "Pending" }
      @machine.on(:confirmed) { @state = "Confirmed" }
      @machine.on(:ignored)   { @state = "Ignored" }
    end

    should "execute callbacks when entering a state" do
      @machine.trigger(:confirm)
      assert_equal "Confirmed", @state

      @machine.trigger(:ignore)
      assert_equal "Confirmed", @state

      @machine.trigger(:reset)
      assert_equal "Pending", @state

      @machine.trigger(:ignore)
      assert_equal "Ignored", @state
    end
  end
end
