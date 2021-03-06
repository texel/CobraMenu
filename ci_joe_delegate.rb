#
#  ci_joe_delegate.rb
#  CobraMenu
#
#  Created by Leigh Caplan on 7/3/10.
#  Copyright (c) 2010 Onehub, Inc. All rights reserved.
#

class CIJoeDelegate
  attr_accessor :data, :response, :error, :delegate, :success_callback, :failure_callback, :complete_callback
  
  def initialize(&block)
    self.data = NSMutableData.new
    yield self if block_given?
  end
  
  def success(&block)
    self.success_callback = block
  end
  
  def failure(&block)
    self.failure_callback = block
  end
  
  def complete(&block)
    self.complete_callback = block
  end
  
  def connection(connection, didReceiveData:data)
    self.data.appendData data
  end
  
  def connection(connection, didReceiveResponse:response)
    self.response = response
  end
  
  def connection(connection, didFailWithError:error)
    self.error = error
    failure_callback.call(data, error) if failure_callback
    complete_callback.call if complete_callback
  end
  
  def connectionDidFinishLoading(connection)    
    success_callback.call(data, response) if success_callback
    complete_callback.call if complete_callback
  end
end
