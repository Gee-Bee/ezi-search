require 'bundler'
require 'bundler/setup'
require 'pry'
require_relative 'search_engine'

$search_engine = SearchEngine.new(File.read('keywords.txt'), File.read('documents.txt'))
