class Object
  def to_js
    "'#{to_s}'"
  end
end

class Fixnum
  def to_js
    to_s
  end
end

class Symbol
  def to_js
    to_s.to_js
  end
end

class Hash
  def to_js
    ret = "{\n"

    each do |val|
      ret += "#{val[0].to_js}: #{val[1].to_js},\n"
    end

    ret += '}'
  end
end

class Array
  def to_js
    to_s.gsub(/"/, "'")
  end
end