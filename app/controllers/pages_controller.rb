class PagesController < ApplicationController
  def hello
  end

  def hello300
    sleep(0.3)
  end

  def hello3000
    sleep(3)
  end
end
