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
  
  def connection(connection, didReceiveData:data)
    self.data.appendData data
  end
  
  def connection(connection, didReceiveResponse:response)
    self.response = response
  end
  
  def connection(connection, didFailWithError:error)
    self.error = error
    failure_callback.call(data, response, error)
  end
  
  def connectionDidFinishLoading(connection)    
    self.success_callback.call(data, response)
  end
end
