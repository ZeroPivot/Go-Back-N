require "receiver.rb"
LENGTH_OF_BUFFER=16
receiver = Receiver.new(LENGTH_OF_BUFFER)
loop do
  event_data = gets.chomp     # user input
  receiver.event(event_data)  # most of what takes place here is in receiver.rb
end


