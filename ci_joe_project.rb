#
#  ci_joe_project.rb
#  CobraMenu
#
#  Created by Leigh Caplan on 7/12/10.
#  Copyright (c) 2010 Onehub, Inc. All rights reserved.
#

class CIJoeProject < NSManagedObject
  
  def self.defaults
    @defaults ||= NSUserDefaultsController.sharedUserDefaultsController.defaults
  end
  
  def self.request(verb, path = '', &block)
    raise "No URL Specified" unless defaults['url']
    
    request = NSMutableURLRequest.new.tap do |r|
      r.URL        = NSURL.URLWithString "#{defaults['url']}/#{path}"
      r.HTTPMethod = verb.to_s.upcase
    end
    
    delegate = CIJoeDelegate.new(&block)
    
    NSURLConnection.connectionWithRequest(request, :delegate => delegate)
  end
  
  %w(get post put delete).each do |verb|
    class_eval %Q{
      def self.#{verb}(path = '', &block)
        self.request(:#{verb}, path, &block)
      end
    }
  end
end
