require 'active_support/inflector'

module ComboBuilder

  module InputScheme
    include ActiveSupport::Inflector

    def self.attr_reader(*args)
      @readers ||= []
      @readers.concat(args)
      super
    end

    def self.readers
      @readers
    end

    attr_reader :name, :title
    attr_reader :motions, :buttons, :modifiers, :display_overrides, :encoding_map

    def initialize
      @name = ''
      @title = ''
      @modifiers = []
      @motions = []
      @buttons = []
      @display_overrides = {}
      @encoding_map = {}
    end

    def cache_key
      self.class.name + 'Cache'
    end

    def to_js
      ret = "function() {\n"

      InputScheme.readers.each do |r|
        val = public_method(r).call
        ret += "this.#{r.to_s.camelize(:lower)} = #{val.to_js};\n"
      end

      ret += "}\n"
    end
  end

  class MarvelInputScheme
    include InputScheme

    def initialize
      @name = 'umvc3'
      @title = 'Ultimate Marvel vs. Capcom 3'
      @modifiers = %w(cr)
      @motions = %w(dp rdp qcf qcb u d f b j sj)
      @buttons = %w(l m h s p1 p2 xx)

      @display_overrides = {
          :sj => '<h4>SJ</h4>',
          :j => '<h4>J</h4>',
          :xx => '<h4>XX</h4>',
          :cr => '<h4>CR</h4>',
          :p1 => '<h4>P1</h4>',
          :p2 => '<h4>P2</h4>'
      }

      @encoding_map = {
          :cr => 1,
          :dp => 2,
          :rdp => 3,
          :qcf => 4,
          :qcb => 5,
          :u => 6,
          :d => 7,
          :f => 8,
          :b => 9,
          :j => 10,
          :sj => 11,
          :l => 12,
          :m => 13,
          :h => 14,
          :s => 15,
          :p1 => 16,
          :p2 => 17,
          :xx => 18
      }
    end
  end

  class StreetFighterInputScheme
    include InputScheme

    def initialize
      @name = 'ssf4'
      @title = 'Super Street Fighter IV: AE'
      @modifiers = %w(cr)
      @motions = %w(dp rdp qcf qcb u d f b j)
      @buttons = %w(lp lk mp mk hp hk)

      @display_overrides = {
          :cr => '<h4>CR</h4>',
          :j => '<h4>J</h4>'
      }

      @encoding_map = {

      }
    end
  end

  def self.input_schemes
    if @input_schemes.nil?
      @input_schemes = {}
      schemes = constants.select { |n|
        c = const_get(n)
        c.is_a?(Class) && c.include?(InputScheme)
      }
      schemes.each do |s|
        c = const_get(s)
        scheme = c.new
        @input_schemes[scheme.name] = scheme
      end
    end

    @input_schemes
  end

end
