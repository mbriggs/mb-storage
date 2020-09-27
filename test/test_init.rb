ENV["CONSOLE_DEVICE"] ||= "stdout"
ENV["LOG_LEVEL"] ||= "_min"

puts RUBY_DESCRIPTION

puts
puts "TEST_BENCH_DETAIL: #{ENV["TEST_BENCH_DETAIL"].inspect}"
puts

require_relative "../init.rb"
require "storage/controls"
require "tempfile"

require "test_bench"; TestBench.activate

Controls = Storage::Controls
