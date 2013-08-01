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
    attr_reader :motions, :buttons, :modifiers, :display_overrides

    def initialize
      @name = ''
      @title = ''
      @modifiers = []
      @motions = []
      @buttons = []
      @display_overrides = {}
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
      @motions = %w(dp rdp qcf qcb u d f b j sj tac dhc ad dj)
      @buttons = %w(l m h s p1 p2 xx)

      @display_overrides = {
          :sj => '<h4>SJ</h4>',
          :j => '<h4>J</h4>',
          :xx => '<h4>XX</h4>',
          :cr => '<h4>CR</h4>',
          :p1 => '<h4>P1</h4>',
          :p2 => '<h4>P2</h4>',
          :tac => '<h4>TAC</h4>',
          :dhc => '<h4>DHC</h4>',
          :ad => '<h4>AD</h4>',
          :dj => '<h4>DJ</h4>'
      }
    end
  end

  class StreetFighterInputScheme
    include InputScheme

    def initialize
      @name = 'ssf4'
      @title = 'Super Street Fighter IV: AE'
      @modifiers = %w(cr)
      @motions = %w(dp rdp qcf qcb u d f b j fadc)
      @buttons = %w(lp lk mp mk hp hk)

      @display_overrides = {
          :cr => '<h4>CR</h4>',
          :j => '<h4>J</h4>',
          :fadc => '<h4>FADC</h4>'
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
