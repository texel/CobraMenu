#
#  application_controller.rb
#  CobraMenu
#
#  Created by Leigh Caplan on 7/2/10.
#  Copyright (c) 2010 Onehub, Inc. All rights reserved.
#

require 'observer'

class ApplicationController
  include Observer

  attr_accessor :status_item, :status_images, :status_menu, :preferences_controller, :defaults, :timer, :status, :last_status
    
  DEFAULT_VALUES = {
    'url'                   => '',
    'ping_interval'         => 60,
    'auto_launch'           => false,
    'sticky_notifications'  => true
  }
  
  def initialize
    super
    
    # We don't want changes to prefs to apply immediately
    NSUserDefaultsController.sharedUserDefaultsController.appliesImmediately = false
    
    self.defaults = NSUserDefaults.standardUserDefaults
    
    defaults.registerDefaults(DEFAULT_VALUES)
            
    bundle = NSBundle.mainBundle
      
    self.status_images = {}
    
    %w(inactive building failure success).each do |status|
      image = NSImage.new.initWithContentsOfFile(bundle.pathForResource(status, :ofType => 'png'))
      status_images[:"#{status}"] = image
    end
  end
    
  def awakeFromNib
    super
    
    # Register super awesome value transformer
    NSValueTransformer.setValueTransformer(NotBlankValueTransformer.new, forName: 'NotBlankValueTransformer')

    self.status_item = NSStatusBar.systemStatusBar.statusItemWithLength(NSSquareStatusItemLength).tap do |s|
      s.menu          = status_menu
      s.highlightMode = true
      s.image         = status_images[:inactive]
    end
    
    observe defaults, :key_path => 'auto_launch' do |old_value, new_value|
      self.auto_launch = new_value
    end
    
    if defaults['url'] == DEFAULT_VALUES['url']
      show_prefs_window self
    else
      schedule_timer
    end
  end
  
  def schedule_timer
    self.timer = NSTimer.timerWithTimeInterval defaults['ping_interval'],
      :target   => self,
      :selector => 'ping_ci:',
      :userInfo => nil,
      :repeats  => true
      
    NSRunLoop.currentRunLoop.addTimer timer, :forMode => NSDefaultRunLoopMode
        
    ping_ci self
  end
  
  def auto_launch=(value)
    puts "changing value"
    
    if value
      LoginItemWrapper.addAppAsLoginItem
    else
      LoginItemWrapper.deleteAppFromLoginItems
    end
  end
  
  def show_prefs_window(sender)
    preferences_controller.showWindow self
    preferences_controller.window.makeKeyAndOrderFront self
    NSApp.activateIgnoringOtherApps true
  end
  
  def ping_ci(sender)
    CIJoeProject.get('ping') do |d|
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
        end
      end
      
      d.failure do |data, error|
        NSLog("Status: #{error}")
        
        self.status = :inactive
      end
    end    
  end
  
  def trigger_build(sender)
    CIJoeProject.post
    ping_ci(self)
  end
  
  def open_in_browser(sender)
    NSWorkspace.sharedWorkspace.openURL NSURL.URLWithString(defaults['url'])
  end
  
  def status=(new_status)
    self.last_status = status
    @status = new_status
    update_image(status)
    
    GrowlNotifier.post_for_status status, defaults['sticky_notifications'] if status_changed?
  end
  
  def status_changed?
    status != last_status
  end
  
  def update_image(name)
    status_item.image = status_images[name]
  end
  
  def show_about_panel(sender)
    NSApp.orderFrontStandardAboutPanel self
    NSApp.activateIgnoringOtherApps true
  end
end
