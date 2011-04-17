#
#  ci_joe_project.rb
#  CobraMenu
#
#  Created by Leigh Caplan on 7/12/10.
#  Copyright (c) 2010 Onehub, Inc. All rights reserved.
#

class CIJoeProject < NSManagedObject
  
  attr_accessor :updated, :application_controller
  
  # Accessors for attributes
  #%w(name url uri_scheme port username password status last_status).each do |m|
    #class_eval %Q{
      #def #{m}
        #valueForKey #{m}
      #end

      #def #{m}=(value)
        #setValue value, forKey: "#{m}"
      #end
    #}
  #end
  
  ## Ruby-like delegators to KVC methods
  def [](key)
    valueForKey key
  end
  
  def []=(key, value)
    setValue value, forKey: key
  end
    
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
      
      def #{verb}(path = '', &block)
        request(:#{verb}, path, &block)
      end
    }
  end

  def request(verb, path = '', &block)
    request = NSMutableURLRequest.new.tap do |r|
      r.URL        = NSURL.URLWithString "#{full_url}/#{path}"
      r.HTTPMethod = verb.to_s.upcase
    end
    
    puts request.URL.description    
    delegate = CIJoeDelegate.new(&block)
    
    NSURLConnection.connectionWithRequest request, delegate: delegate
  end

  def full_url
    auth_string  = "#{username}:#{password}@" if username && password
    "#{uri_scheme}#{auth_string}#{url}:#{port}"
  end

  def update!(sender)
    self.updated = false
    
    get('ping') do |d|
      d.success do |data, response|
        NSLog("Status: #{response.statusCode}")
        
        case response.statusCode
        when 200
        self.status = :success
        when 412
          if data.to_s == 'building'
            self.status = :building
          else
            self.status = :failure
          end
        when 403
          self.status = :forbidden
        else
          self.status = :inactive
        end
      end
      
      d.failure do |data, error|
        NSLog("Status: #{error}")
        
        self.status = 'inactive'
      end
      
      d.complete do
        self.updated = true
      end
    end
  end
  alias :update :update! # IB doesn't like exclamation points in its bindings :\

  def status=(new_status)
    self.last_status = status

    self.setValue new_status, forKey: 'status'
  end

  def open_in_browser(sender)
    NSWorkspace.sharedWorkspace.openURL NSURL.URLWithString(full_url)
  end

  def trigger_build(sender)
    post do |req|
      req.success { update! self }
    end
  end

  def validateUserInterfaceItem(item)
    true
  end

  def enabled?
    [1, true].include? enabled
  end

  def validateMenuItem(item)
    puts "validation"
    true
  end
end
