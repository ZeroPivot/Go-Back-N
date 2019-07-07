# A doubly linked list I implemented back when I first began using Ruby; it works I suppose.

class LinkedList
  attr_accessor :size, :first, :last
  def initialize(object=nil)
  @first = Node.new(nil)
  @last = Node.new(nil)
  @first.next = @last
  @last.prev = @first
  @size = 0
    if (object != nil)
      insertFront(object)      
    end
    
  end
    


  def insertFront(object=nil) #  
    tempNode = Node.new(object)
    tempNode.prev = @first
    tempNode.next = @first.next
    @first.next.prev = tempNode
    @first.next = tempNode
    @size += 1
    return @first.next    
  end
  
  #rename this to insertBack, and the opposite version insertFront.
  def insertBack(object=nil) #we need more of these
    tempNode = Node.new(object)
    tempNode.next = @last
    tempNode.prev = @last.prev
    @last.prev.next = tempNode
    @last.prev = tempNode
    @size += 1
    return @last.prev    
    
  end
  
  def rightSentinelNode #in the case where we want the very first node    
      return @last
  end
  
  def leftSentinelNode #in the cases 
      return @first    
  end
  
  #def getNext
  
  def setLast(object)
	temp = getLastNode
	success = false
	if (temp != nil)
		temp.object = object
		success = true
	end
	return success
  end
  
  def setFirst(object) #
    temp = getFirstNode
	success = false
	if (temp != nil)
		temp.object = object
		success = true
	end
	return success
  end
  
  def debug
    traverseNode = @first
    while (traverseNode != nil)
      yield traverseNode #puts(traverseNode.object)
      traverseNode = traverseNode.next
    end
  end

  def removeNode #I think self would work in this context, not that it matters
   puts self.object
  end
  
  
  def insertBefore(nodeLocation, object=nil) #returns the new inserted node, or the same nodeLocation if it fails to insert (only one case!).
	insertion = nodeLocation
	if (nodeLocation != @first)
		tempNode = Node.new(object)
		tempNode.prev = nodeLocation.prev
		tempNode.next = nodeLocation
		nodeLocation.prev.next = tempNode
		nodeLocation.prev = tempNode
		insertion = tempNode
		@size += 1
	end
	return insertion
end

#def insertAfter(nodeLocation, object=nil) <-- bah, too much work and unnecessary most of the time


def getLastNode #not counting the sentinel node
	unless (@size == 0)
		return @last.prev
	else
		return nil
	end
end

def getFirstNode #get the pointer to the first node
	unless (@size == 0)
		return @first.next
	else
		return nil
	end

end

def getFirstData #get the first Node's data (or nil if there aren't any)
	return getFirstNode.object
end

def getLastData #get the last Node's data (or nil " -- " )
	return getLastNode.object
end


def getData(nodeLocation)
	

end	



  class Node
    attr_accessor :next
    attr_accessor :prev
    attr_accessor :object
    
    def initialize(object=nil)
      @object = object
    end
    
    def remove
    end
  end
  
  
end



