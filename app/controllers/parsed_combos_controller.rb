require 'combobuilder'

class ParsedCombosController < ApplicationController
  def show
    info = params[:id]
    if info =~ /(.*)\$(.*)/
      @scheme = ComboBuilder.input_schemes[$~.captures[0]]
      if @scheme.nil?
        @nodes = [ComboBuilder::ErrorNode.new('Unknown input scheme')]
      else
        combo = $~.captures[1].gsub(/[!|@]/) { |c| (c == '!' ? '.' : ' ') }
        @nodes = ComboBuilder::Parser.parse(@scheme, combo)
      end
    else
      @nodes = [ComboBuilder::ErrorNode.new('Invalid combo string')]
    end

    @errors = @nodes.select { |n| n.type == :error }
    respond_to do |format|
      format.html { render layout: false }
      format.json { render :json => @nodes }
    end
  end
end
