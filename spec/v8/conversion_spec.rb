require 'spec_helper'
require 'bigdecimal'
describe V8::Conversion do
  it "can embed BigDecimal values" do
    cxt = V8::Context.new
    cxt['big'] = BigDecimal.new('1.1')
    cxt['big'].should eql BigDecimal.new('1.1')
  end

  it "doesn't try to use V8::Conversion::Class::* as root objects" do
    klass = Class.new do
      class << self
        def test
          Set.new
        end
      end
    end

    klass.test.should be_instance_of(::Set)
  end
end
