require 'combobuilder'

class CombosController < ApplicationController
  def show
  end

  def new
    @input_schemes = ComboBuilder::input_schemes
    @combo = ''
  end

  def edit
    @input_schemes = ComboBuilder::input_schemes
    @combo = ComboBuilder.decode(params[:id])
  end
end
