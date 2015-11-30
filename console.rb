require_relative 'config'
require 'colorize'

loop do
  print 'Query: '.blue
  query = gets.chomp
  $search_engine.search(query).
    each {|doc| puts "#{doc[:content][/[^\r\n]+/]}; #{doc[:sim_tf_idf].to_f}"}
end
