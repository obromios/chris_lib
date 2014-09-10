class AccessTestController < ApplicationController
  def index

  end

  def edit
  	redirect_to access_test_index_path
  end

  def update
  	redirect_to access_test_index_path
  end
end
