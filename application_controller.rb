#
#  application_controller.rb
#  CobraMenu
#
#  Created by Leigh Caplan on 7/2/10.
#  Copyright (c) 2010 Onehub, Inc. All rights reserved.
#

class ApplicationController < NSObject
  attr_accessor :status_item, :status_images, :status_menu, :preferences_controller, :defaults
  
  def initialize
    super
    
    # We don't want changes to prefs to apply immediately
    NSUserDefaultsController.sharedUserDefaultsController.appliesImmediately = false
    
    self.defaults = NSUserDefaultsController.sharedUserDefaultsController.defaults
    
    bundle = NSBundle.mainBundle
    
    self.status_images = {}
    
    %w(inactive building failure success).each do |status|
      image = NSImage.new.initWithContentsOfFile(bundle.pathForResource(status, :ofType => 'png'))
      status_images[:"#{status}"] = image
    end
  end
    
  def awakeFromNib    
    self.status_item = NSStatusBar.systemStatusBar.statusItemWithLength(NSSquareStatusItemLength).tap do |s|
      s.menu          = status_menu
      s.highlightMode = true
      s.image         = status_images[:inactive]
    end    
  end
  
  def show_prefs_window(sender)
    preferences_controller.showWindow self
    preferences_controller.window.makeKeyAndOrderFront self
    NSApp.activateIgnoringOtherApps true
  end
  
  def ping_ci(sender)
    NSLog("No URL provided!") and return unless defaults['url']
    
    request = NSMutableURLRequest.new
    request.URL = NSURL.URLWithString defaults['url']
    
    delegate = CIJoeDelegate.new
    
    delegate.success do |data, response|
      NSLog("Status: #{response.statusCode}")
      NSLog("Data: #{data}")
    end
    
    delegate.failure do
      NSLog("BOO")
    end
    
    NSURLConnection.connectionWithRequest(request, :delegate => delegate)
  end
end
