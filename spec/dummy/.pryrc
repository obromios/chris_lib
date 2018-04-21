# exception handler to allow recovery after sql error
# https://travisofthenorth.com/blog/2016/10/15/postgres-rails-sandbox?utm_source=rubyweekly&utm_medium=email
Pry.config.exception_handler = proc do |output, exception, _pry_|
  output.puts "#{exception.class}: #{exception.message}"
  output.puts exception.backtrace.first

  if exception.instance_of?(ActiveRecord::StatementInvalid) && exception.original_exception.is_a?(PG::Error)
    output.puts 'Rolling back transaction and starting a new one!'
    connection = ActiveRecord::Base.connection
    connection.rollback_db_transaction
    connection.begin_db_transaction
  end
end
load './scratch.rb'
include Scratch
