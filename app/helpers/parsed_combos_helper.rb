module ParsedCombosHelper

  def display_part(scheme, part)
    if scheme.display_overrides.has_key?(part.to_sym)
      return scheme.display_overrides[part.to_sym]
    end

    "<img src=\"#{image_path('moves/' + part + '.png')}\" />"
  end

end
