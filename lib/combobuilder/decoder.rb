require 'base64'

module ComboBuilder

  def self.decode(data)
    combo = Base64.decode64(data)
    scheme = input_schemes.values.select {|v| combo.start_with?(v.name)}.first
    map = scheme.encoding_map.inverse

    ret = ''
    combo.each_byte do |b|
      if b == 0
        ret += ' '
      else
        ret += map[b].to_s
        if scheme.modifiers.contains(part)
          ret += '.'
        end
      end
    end

    ret
  end

end