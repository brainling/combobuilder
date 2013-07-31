class HomeController < ApplicationController
  def index
    redirect_to new_combo_url
  end
end
