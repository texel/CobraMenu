#
#  application_controller.rb
#  CobraMenu
#
#  Created by Leigh Caplan on 7/2/10.
#  Copyright (c) 2010 Onehub, Inc. All rights reserved.
#

class ApplicationController < NSObject
  attr_accessor :status_item, :status_images, :status_menu, :preferences_controller, :defaults, :timer
  
  # TODO: Make this a preference
  TIME_INTERVAL = 60
  
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
    
    if defaults['url']
      schedule_timer
    else
      show_prefs_window
    end
  end
  
  def schedule_timer
    self.timer = NSTimer.timerWithTimeInterval TIME_INTERVAL,
      :target   => self,
      :selector => 'ping_ci:',
      :userInfo => nil,
      :repeats  => true
      
    NSRunLoop.currentRunLoop.addTimer timer, :forMode => NSDefaultRunLoopMode
    
    timer.fire
  end
  
  def show_prefs_window(sender)
    preferences_controller.showWindow self
    preferences_controller.window.makeKeyAndOrderFront self
    NSApp.activateIgnoringOtherApps true
  end
  
  def ping_ci(sender = self)
    NSLog("No URL provided!") and return unless defaults['url']
    
    request = NSMutableURLRequest.new
    request.URL = NSURL.URLWithString defaults['url']
    
    delegate = CIJoeDelegate.new do |d|
      d.success do |data, response|
        NSLog("Status: #{response.statusCode}")
        
        data_string = data.to_s
        
        # The CI Joe ping action doesn't give us enough info to
        # figure out whether we've succeeded, are still building, or have failed.
        # Instead, we regex match the html response. Ghetto? Yes.
        if data_string =~ /building|starting/i
          update_image :building
        elsif data_string =~ /worked/i
          update_image :success
        else
          update_image :failure
        end
      end
      
      d.failure do |data, response|
        NSLog("Status: #{response.statusCode}")
        update_image :inactive
      end
    end
    
    NSURLConnection.connectionWithRequest(request, :delegate => delegate)
  end
  
  def update_image(name)
    status_item.image = status_images[name]
  end
end