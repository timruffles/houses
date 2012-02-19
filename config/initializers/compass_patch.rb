
module Compass::SassExtensions::Functions::GradientSupport

  class ColorStop < Sass::Script::Literal

    def initialize(color, stop = nil)
      self.options = {}
      if color.is_a?(Sass::Script::String) && color.value == 'transparent'
        color = Sass::Script::Color.new([0,0,0,0])
        color.options = {}
      end
      unless Sass::Script::Color === color || Sass::Script::Funcall === color
        raise Sass::SyntaxError, "Expected a color. Got: #{color}"
      end
      if stop && !stop.is_a?(Sass::Script::Number)
        raise Sass::SyntaxError, "Expected a number. Got: #{stop}"
      end
      self.color, self.stop = color, stop
    end

  end

  module Functions

    def color_stops(*args)
      Sass::Script::List.new(args.map do |arg|
        case arg
        when ColorStop
          arg
        when Sass::Script::Color
          ColorStop.new(arg)
        when Sass::Script::List
          ColorStop.new(*arg.value)
        when Sass::Script::String
          ColorStop.new(arg)
        else
          raise Sass::SyntaxError, "Not a valid color stop: #{arg.class.name}: #{arg}"
        end
      end, :comma)
    end

  end
end

