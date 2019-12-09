var CircularQueue = function(length){
  this.storage = [];
  this.maxLength = length;
  this.head = 0;
  this.tail = 0;
}

CircularQueue.prototype.enqueue = function(item){
  //code to add to the queue class
  //if head and tail are pointed to the same index 
  if(this.head === this.tail){
    //if item is empty
    if(this.storage[this.head] === undefined){
      //add item to index 0
      this.storage[0] = item;
    } else {
    //if there is an item 
      //add item to next index
      this.storage[1] = item;
      //point tail next index
      this.tail = 1;
    }
  } else if(this.head !== this.tail) {
   //get the index that tail should go next
     var nextIndex = (this.tail + 1) % this.maxLength;
   //if index is empty
     if (this.storage[nextIndex] === undefined) {
       //add item to index
       this.storage[nextIndex] = item;
       //point tail to index
       this.tail = nextIndex;
     } else {
      //queue is empty
      console.log('queue is full right now!')
     //return
      return;
    }
  }
 return this.storage;
}

CircularQueue.prototype.dequeue = function(){
  //code to remove from the queue class
  //if the head is pointing to an item
  if(this.storage[this.head] !== undefined){
    //make a copy of item at head index
    //splice out the item 
   var oldHead = this.head;
   this.storage[this.head] = undefined;
  //point head at next index
   this.head = oldHead + 1;
    //return the old head
   return this.storage[oldHead];
  } else {
    console.log('there is nothing in the queue!')
  }
}