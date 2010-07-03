#
#  ci_joe_delegate.rb
#  CobraMenu
#
#  Created by Leigh Caplan on 7/3/10.
#  Copyright (c) 2010 Onehub, Inc. All rights reserved.
#

=begin
  - (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
  - (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response;
  - (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
  - (void)connectionDidFinishLoading:(NSURLConnection *)connection;
=end

class CIJoeDelegate
  attr_accessor :data, :response, :error, :delegate, :success_callback, :failure_callback
  
  def initialize
    self.data = NSMutableData.new
  end
  
  def success(&block)
    self.success_callback = block
  end
  
  def failure(&block)
    self.failure_callback = block
  end
  
  def connection(connection, didReceiveData:data)
    NSLog("Received Data")
    self.data.appendData data
  end
  
  def connection(connection, didReceiveResponse:response)
    NSLog("Received Response")
    self.response = response
  end
  
  def connection(connection, didFailWithError:error)
    NSLog("Failed")
    self.error = error
    failure_callback.call(data, error)
  end
  
  def connectionDidFinishLoading(connection)
    NSLog("Finished Loading")
    
    self.success_callback.call(data, response)
  end
end
