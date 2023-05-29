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
      insert_front(object)      
    end
  end
  
  def test;puts "test";exit;end
  
  def right_sentinel_node;@last;end
  def left_sentinel_node;@first;end
  def get_first_data;get_first_node.object;end
  def get_last_data;get_last_node.object;end
  
  def insert_front(object=nil) #  
    temp_node = Node.new(object)
    temp_node.prev = @first
    temp_node.next = @first.next
    @first.next.prev = temp_node
    @first.next = temp_node
    @size += 1
    return @first.next    
  end
  
  def insert_back(object=nil) #we need more of these
    temp_node = Node.new(object)
    temp_node.next = @last
    temp_node.prev = @last.prev
    @last.prev.next = temp_node
    @last.prev = temp_node
    @size += 1
    return @last.prev      
  end
 
  def set_last(object)
	  temp = get_last_node
	  success = false
	  if (temp != nil)
		  temp.object = object
		  success = true
	  end
	  return success
  end
  
  def set_first(object) #
    temp = get_first_node
	  success = false
	  if (temp != nil)
		  temp.object = object
		  success = true
	  end
	  return success
  end
  
  def traverse
    traverse_node = get_first_node
    while (traverse_node.next != nil)
      yield traverse_node 
      traverse_node = traverse_node.next
    end
  end

  def insert_before(node_location, object=nil) 
	insertion = node_location
	if (node_location != @first)
		temp_node = Node.new(object)
		temp_node.prev = node_location.prev
		temp_node.next = node_location
		node_location.prev.next = temp_node
		node_location.prev = temp_node
		insertion = temp_node
		@size += 1
	end
	return insertion
end

def get_last_node 
	unless (@size == 0)
		return @last.prev
	else
		return nil
	end
end

def get_first_node 
	unless (@size == 0)
		return @first.next
	else
