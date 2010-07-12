#
#  ci_joe_project.rb
#  CobraMenu
#
#  Created by Leigh Caplan on 7/12/10.
#  Copyright (c) 2010 Onehub, Inc. All rights reserved.
#

class CIJoeProject
  
  def self.defaults
    @defaults ||= NSUserDefaultsController.sharedUserDefaultsController.defaults
  end
  
  def self.request(verb, &block)
    raise "No URL Specified" unless defaults['url']
    
    request = NSMutableURLRequest.new
    request.URL = NSURL.URLWithString defaults['url']
    request.HTTPMethod = verb.to_s.upcase
    
    delegate = CIJoeDelegate.new(&block)
    
     NSURLConnection.connectionWithRequest(request, :delegate => delegate)
  end
  
  %w(get post put delete).each do |verb|
    class_eval %Q{
      def self.#{verb}(&block)
        self.request(:#{verb}, &block)
      end
    }
  end
end
