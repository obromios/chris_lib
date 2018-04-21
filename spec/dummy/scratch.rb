# https://hackernoon.com/as-rails-developers-it-is-imperative-that-we-be-comfortable-and-productive-in-the-console-7a72a78d97d3
module Scratch
  def scratch
    load __FILE__
  end

  def temp
    reload!
  end

  require 'ruby-progressbar'
  # Iterates through scope while displaying a progress bar
  def each_with_progress_bar(scope, &block)
    progress_bar = ProgressBar.create
    progress = progress_bar(scope.count)
    scope.find_each do |item|
      block.call(item).tap do
        progress.increment
      end
    end
  end
 # graphs
 # http://effectif.com/ruby/manor/data-visualisation-with-ruby
end