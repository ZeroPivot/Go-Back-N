class Receiver
LENGTH=3
  require "LinkedList.rb" #uses a doubly linked list as the data structure
  def initialize(length,offset)
    @offset=offset
    @list=LinkedList.new
    raise "length cannot be 0" if length==0
    @length=length
    @length.times { |i| @list.insertBack( {:seq=>@offset+i+1,:data=>nil,:have=>false} ) } #no more off-by-1 errors, muahahahaha 
                                                                                    #(the object in each node contains a hash with the sequence number(:seq),
                                                                                    # and one with the data represented by a 50 length array)
    @debug=true
    setRange(@offset..@list.getLastNode.object[:seq])
    @receiving = false
	@buffer_size=0 #buffer full if @buffer_size == @length
    #@range = (@offset..@list.getLastNode.object[:seq])
	@location = @list.getFirstNode #current position in the buffer
  end
  
  #for actual node id, negate offset from :seq, but this is unnecessary
  def list #returns the actual data structure, for debugging purposes only one would hope.
    @list
  end
  
  def range #can find out of a frame is within the buffer or not by range.member? frame#
    @range
  end
  
  def setRange(range)
    @range = (range)
  end
  
  def changeOffset(offset) #this shouldn't have to be used more than once  ...

	traversal do |node|
	
	  debug("before: #{node.object[:seq]}")
      node.object[:seq] -= @offset
      node.object[:seq] += offset
      debug("after: #{node.object[:seq]}")
	
	end
    @offset = offset
    setRange(@offset..@list.getLastNode.object[:seq])
  end
  
  def minSEQ?
    @list.getFirstNode.object[:seq]
  end
  
  def maxSEQ? #the limit of the buffer
    @list.getLastNode.object[:seq]
  end
  
  def debug(string)
    puts string if @debug
  end
    
  def traversal
  traverse=@list.getFirstNode
  while (traverse != @list.rightSentinelNode)
   yield traverse
  traverse = traverse.next
  end
  end
	
  def noHas
	traversal{|node| node.object[:have]=false}
  end

  def full?
  traversal{|node| return false if !node.object[:have]}
  return true
  end
	
  def nakCheck #true if nak exists
	#while node.data[:seq] <= @location
		traversal do |node|
		return false if node.object[:seq] > @location.object[:seq]
			if !node.object[:have]
				nak(node.object[:seq])
				return true
			end
		end
	#end
	
	return false
  end
  
  def nak(loc=nil)
   puts "NAK #{@location.object[:seq]}" if loc==nil
   puts "NAK #{loc}" if loc!=nil
  end
	
  def ack
	puts "ACK #{@location.object[:seq]}"
  end	
	
  def changeLocation(frame)
	traversal do |node|
		if node.object[:seq]==frame
			@location=node
			break
		end
	end
	@location
  end	
	
  def event(string) #here's where it gets interesting; the event function is what makes this move
    packet=string.split(/ /,3) #since the data is unimportant compared to the first two words, this splits the packet into a 3-length array
    command=packet[0]                            # [0] contains SYN or DAT or FIN, [1] contains the frame #, and [2] contains the DATA being sent inside said frame
	frame=packet[1].to_i
	data=packet[2]
    # if SYN, you have the numbers in 2nd subscript--this also sets up the offset + 1 -> SYN 12345 => ACK 123456 (123456 is starting point)
    # if DAT, you have the frame number following it, followed by 50 BYTES OF DATA; make sure this is 50 BYTES (.length); THE FRAME NUMBER
    #  GOES INTO A CERTAIN SEQ in the linked list! Will need to implement a linked list search based on location
    # if FIN, ends data being transmitted, and prints entirety of the BUFFER
    
    # note: NAK means one will have to place in data in a certain node of the linked list! This is trivial :/
    case command #part of the array containing SYN DAT or FIN
    when "SYN" #start receiving data
	debug("made it this far")
      if !@receiving #do nothing if we're already receiving?		
		changeOffset(frame)
		ack
		@receiving = true
      end
	  
    when "DAT" #search for appropriate location of buffer, check to see if in range, check to see if data length is EXACTLY 50
      #full=false
	  if @receiving and data != nil and data.size == LENGTH
		if range.member? frame #this frame is within the buffer
		
		
			if frame == @location.object[:seq] #right on
				@location.object[:data]=data
				@location.object[:have]=true
				
				nakCheck 
				#	ack if !full?
				#end
				
				@location=@location.next if @location.next != @list.rightSentinelNode
				ack
				
				if full?
					
					noHas
					@location = @list.getFirstNode
					#ack
				end
			#check to see if its full
			
			elsif frame > @location.object[:seq] #this is how NAKs start ...
				changeLocation(frame)
				@location.object[:data]=data
				@location.object[:have]=true
				if !nakCheck
					ack
				end
			
			#check to see if its full
			
			elsif frame < @location.object[:seq] #fixing a NAK?
				normalloc=@location.object[:seq]
				changeLocation(frame)
				@location.object[:data]=data
				@location.object[:have]=true
				ack
				changeLocation(normalloc)
				nakCheck
			end
			
			#check to see if its full
			
		#else #if it isn't, just do a nak check?
		end
	  end
    when "FIN"
	 @list.debug{|node| puts node.object[:data] if node != @list.rightSentinelNode and node != @list.leftSentinelNode and node.object[:data] != nil};exit
    else
      @list.debug{|node| puts node.object[:data] if node != @list.rightSentinelNode and node != @list.leftSentinelNode}
  end  
    
  
end
  
end