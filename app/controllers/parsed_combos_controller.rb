class ParsedCombosController < ApplicationController
  respond_to :json, :html

  def show
    combo = params[:id]
    m = /.*\$(.*)/.match(combo)
    if m.nil?
      @nodes = ComboBuilder::ErrorNode.new('Invalid combo string')
    else
      @scheme = ComboBuilder::MarvelInputScheme.new
      @nodes = ComboBuilder::Parser.parse(@scheme, m.captures[0])
    end
  end
end
