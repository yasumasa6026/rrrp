class SampleJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts "@@@@@@SampleJob is Started@@@@@@@@@@"
    puts ""
    puts ""
    puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    puts "@@@@@@something job@@@@@@@@@@@@@@@@@"
    puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    puts ""
    puts ""
    puts "@@@@@@SampleJob is done@@@@@@@@@@@@@"
  end
end
