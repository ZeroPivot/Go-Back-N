class Receiver
require "LinkedList.rb" # !YAY?
LENGTH=50,MAX_BOUND=99999
  def initialize(length,offset=0) # :seq contains the sequence#; :data contains the packet data; :have is for tracking purposes only...
    raise "length cannot be 0" if length==0
    @debug=false
    @receiving = false
    @offset=offset
    @list=LinkedList.new
    @length=length
    @length.times { |i| @list.insertBack( {:seq=>@offset+i+1,:data=>nil,:have=>false} ) } #no more off-by-1 errors, muahahahaha (creating the linked list of n length)                                                                                 
    setRange(@offset..@list.getLastNode.object[:seq]) #ranges makes out of bound packets trivial.
	  @location = @list.getFirstNode #current position in the buffer
  end
  def padder(seqnum,syn_max_len=5);seqnum.to_s.length<=syn_max_len ? ("0"*(syn_max_len-seqnum.to_s.length) + seqnum.to_s) : (seqnum.to_s);end
  def range;@range;end #can find out of a frame is within the buffer or not by range.member? frame#  
  def setRange(range);@range = (range);end
  def list;@list;end #returns the actual data structure, for debugging purposes only one would hope.
  def minSEQ?;@list.getFirstNode.object[:seq];end
  def maxSEQ?;@list.getLastNode.object[:seq];end
  def debug(string);puts string if @debug;end
  def nak(loc=nil);loc==nil ? (puts "NAK #{padder(@location.object[:seq])}") : (puts "NAK #{padder(loc)}");end
  def ack(val=nil);val==nil ? (puts "ACK #{padder(@location.object[:seq])}") : (puts "ACK #{padder(val)}");end
  def multi;yield;end
  def full?;@list.traverse{|node| return false if !node.object[:have]};true;end
  def noHas;@list.traverse{|node| node.object[:have]=false};end #cheezburger... resets every node to false--for data structure purposes

def changeOffset(offset) #used to sync the offset with the sender, or to reset it to 0
	  @list.traverse do |node|
	     debug("before: #{node.object[:seq]}")
       node.object[:seq] -= @offset
       node.object[:seq] += offset
       debug("after: #{node.object[:seq]}")	
	    end
     @offset = offset
     setRange(@offset..@list.getLastNode.object[:seq])
 end

  def nakCheck  #true if nak exists; this was also implemented when I didn't fully understand go-back-n...
		@list.traverse do |node|
		return false if node.object[:seq] > @location.object[:seq]
			if !node.object[:have]
				nak(node.object[:seq])
				return true
			end
		end
	  return false
  end

  def changeLocation(frame) #I implemented this back when I didn't fully understand go-back-n; this program was actually more complex before...
	@list.traverse do |node|
		if node.object[:seq]==frame
			@location=node
			break
		end
	end
	  @location
  end	
  
	#### Here's where it gets interesting; the event function is what makes this move. ###
  def event(string) 
    packet=string.split(/ /,3)  # Since the data is unimportant compared to the first two words, this splits the packet into a 3-length array
    command=packet[0]           # Contains the sender's command          
	  frame= packet[1].to_i       # The frame
	  data=packet[2]              # The sender's data
	  
    case command #every packet the sender sends takes place here 
      when "SYN" #start receiving data
	      debug("made it this far")
        if !@receiving #do nothing if we're already receiving, otherwise, magic   
		      changeOffset(frame)
		      ack(frame+1)
		      @receiving = true
        end
      when "DAT" #search for appropriate location of buffer, check to see if in range, check to see if data length is EXACTLY 50
	      if @receiving and range.member? frame #this frame is within the buffer if true
            if full?
              debug("full before")
              noHas
              @location = @list.getFirstNode
            end
            if frame == @location.object[:seq]
              if frame==MAX_BOUND
                changeOffset(-1)
              end
              @location.object[:data]=data; @location.object[:have]=true
              if @location.next == @list.rightSentinelNode
                noHas
                changeOffset(frame)
                @location = @list.getFirstNode
                ack            
              else
                @location=@location.next
                ack
              end          
            elsif frame >  @location.object[:seq]
              nak #nak the current location...
            else #LAST THING ADDED; MAY OR MAY NOT WORK
              puts "out of bounds error"
            end
		      end
      when "FIN" :  @list.traverse{|node| puts node.object[:data] if node != @list.rightSentinelNode and node != @list.leftSentinelNode and node.object[:data] != nil};exit
  end   
end
end

