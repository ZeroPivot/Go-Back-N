require "LinkedList.rb"
require "receiver.rb"

LENGTH=3
receiver = Receiver.new(LENGTH,0)
loop do
  
  event_data = gets.chomp#.chomp # (WaitForEvent();)
  $stdout.flush
  #puts "past stdin"
  receiver.event(event_data)  
  
end



#receiver.changeOffset(1213423) #note SYN 12345 and DAT 123456; DAT = SYN FRAME + 1
#puts receiver.range.member? 0
#receiver.changeOffset(0)

