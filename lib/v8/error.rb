module V8
  class Error < StandardError
    attr_reader :value
    def initialize(message, value)
      super(message)
      @value = value
    end

    module Try
      def try
        context = V8::Context.current
        V8::C::TryCatch() do |trycatch|
          result = yield
          if trycatch.HasCaught()
            V8::Error(trycatch.Exception())
          else
            result
          end
        end
      end
    end

    module Protect
      def protect
        yield
      rescue Football => e
        e.kickoff!
      rescue Exception => e
        e.extend Football
        e.kickoff!
      end
    end

    module Football
      def kickoff!
        error = V8::C::Exception::Error(message)
        error.SetHiddenValue("rr::Football", V8::C::External::New(self))
        V8::C::ThrowException(error)
      end
    end

  end

  def self.Error(exception)
    value = exception.to_ruby
    if !exception.kind_of?(V8::C::Value)
      raise V8::Error.new(exception.to_s, value)
    elsif exception.IsNativeError()
      if football = exception.GetHiddenValue("rr::Football")
        raise football.Value()
      else
        raise V8::Error.new(exception.Get("message").to_ruby, value)
      end
    else
      raise V8::Error.new(exception.ToString().to_ruby, value)
    end
  end
  const_set :JSError, Error
end