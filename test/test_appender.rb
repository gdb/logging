# $Id$

require 'test/setup.rb'

module TestLogging

  class TestAppender < Test::Unit::TestCase
    include LoggingTestCase

    def setup
      super

      ::Logging.define_levels %w(debug info warn error fatal)
      @levels = ::Logging::LEVELS
      @event = ::Logging::LogEvent.new('logger', @levels['debug'],
                                       ['message'], false)
      @appender = ::Logging::Appender.new 'test_appender'
    end

    def test_append
      ary = []
      @appender.instance_variable_set :@ary, ary
      def @appender.write( str ) @ary << str end

      assert_nothing_raised {@appender.append @event}
      assert_equal "DEBUG  logger : message\n", ary.pop

      @appender.level = :info
      @appender.append @event
      assert_nil ary.pop

      @event.level = @levels['info']
      @appender.append @event
      assert_equal " INFO  logger : message\n", ary.pop

      @appender.close
      assert_raise(RuntimeError) {@appender.append @event}
    end

    def test_close
      assert_equal false, @appender.closed?

      @appender.close
      assert_equal true, @appender.closed?
    end

    def test_closed_eh
      assert_equal false, @appender.closed?

      @appender.close
      assert_equal true, @appender.closed?
    end

    def test_concat
      ary = []
      @appender.instance_variable_set :@ary, ary
      def @appender.write( str ) @ary << str end

      assert_nothing_raised {@appender << 'log message'}
      assert_equal 'log message', ary.pop

      @appender.level = :off
      @appender << 'another log message'
      assert_equal 'another log message', ary.pop

      layout = @appender.layout
      def layout.footer() 'this is the footer' end

      @appender.close
      assert_raise(RuntimeError)  {@appender << 'log message'}
      assert_equal 'this is the footer', ary.pop
    end

    def test_initialize
      assert_raise(TypeError) {::Logging::Appender.new 'test', :layout => []}

      layout = ::Logging::Layouts::Basic.new
      @appender = ::Logging::Appender.new 'test', :layout => layout
      assert_same layout, @appender.instance_variable_get(:@layout)
    end

    def test_layout
      assert_instance_of ::Logging::Layouts::Basic, @appender.layout
    end

    def test_layout_eq
      layout = ::Logging::Layouts::Basic.new
      assert_not_equal layout, @appender.layout

      assert_raise(TypeError) {@appender.layout = Object.new}
      assert_raise(TypeError) {@appender.layout = 'not a layout'}

      @appender.layout = layout
      assert_same layout, @appender.layout
    end

    def test_level
      assert_equal 0, @appender.level
    end

    def test_level_eq
      assert_equal 0, @appender.level

      assert_raise(ArgumentError) {@appender.level = -1}
      assert_raise(ArgumentError) {@appender.level =  6}
      assert_raise(ArgumentError) {@appender.level = Object}
      assert_raise(ArgumentError) {@appender.level = 'bob'}
      assert_raise(ArgumentError) {@appender.level = :wtf}

      @appender.level = 'INFO'
      assert_equal 1, @appender.level

      @appender.level = :warn
      assert_equal 2, @appender.level

      @appender.level = 'error'
      assert_equal 3, @appender.level

      @appender.level = 4
      assert_equal 4, @appender.level

      @appender.level = 'off'
      assert_equal 5, @appender.level

      @appender.level = :all
      assert_equal 0, @appender.level
    end

    def test_name
      assert_equal 'test_appender', @appender.name
    end

  end  # class TestAppender
end  # module TestLogging

# EOF
