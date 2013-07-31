class HomeController < ApplicationController
  def index
    redirect_to '/combos/new'
  end
end
