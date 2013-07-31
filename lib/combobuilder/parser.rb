module ComboBuilder

  module ComboNode
    attr_accessor :type
  end

  class ErrorNode
    include ComboNode

    attr_accessor :message

    def initialize(msg)
      @type = :error
      @message = msg
    end
  end

  class SequenceNode
    include ComboNode

    attr_accessor :parts, :modifier

    def initialize
      @type = :sequence
      @parts = []
    end

    def has_modifier?
      !modifier.nil?
    end
  end

  module Parser
    def self.parse(input_scheme, text)
      ctx = Parser::Context.new(input_scheme, text)

      parts = text.split(' ')
      parts = %w( text ) unless parts.length > 0

      nodes = []
      parts.each do |part|
        if part =~ /.*\..+/
          nodes << parse_modifier_part(ctx, part)
        else
          nodes << parse_any_part(ctx, part)
        end
      end

      nodes
    end

    private

    class Context
      attr_accessor :input_scheme, :text, :button_list, :any_list

      def initialize(input_scheme, text)
        @input_scheme = input_scheme
        @text = text

        @button_list = build_button_list
        @any_list = build_any_list
      end

      private

      def build_button_list
        @input_scheme.buttons.sort.reverse
      end

      def build_any_list
        any = @input_scheme.buttons.concat(@input_scheme.motions)
        any.sort.reverse
      end
    end

    def self.parse_modifier_part(ctx, part)
      parts = part.split('.')
      modifier = parts[0]
      sequence = parts[1]

      if ctx.input_scheme.modifiers.index(modifier).nil?
        return ErrorNode.new("Unknown modifier: #{modifier}")
      end

      node = SequenceNode.new
      node.modifier = modifier
      parse_sequence(sequence, ctx.button_list, node)
    end

    def self.parse_any_part(ctx, part)
      parse_sequence(part, ctx.any_list, SequenceNode.new)
    end

    def self.parse_sequence(part, list, node)
      loop do
        found = false

        unless part.nil?
          list.each do |btn|
            if part.start_with?(btn)
              found = true
              part = part.slice(btn.length, part.length - btn.length)
              node.parts << btn
            end
          end
        end

        break if !found || part.length == 0
      end

      if part.nil? || part.length > 0
        return ErrorNode.new("Unknown input in sequence: #{part}")
      end

      node
    end

  end

end