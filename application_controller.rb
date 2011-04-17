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
  attr_accessor :projects_window, :projects_controller, :app_delegate, :uri_schemes
    
  DEFAULT_VALUES = {
    'url'                   => '',
    'ping_interval'         => 60,
    'auto_launch'           => false,
    'sticky_notifications'  => true
  }
  
  STATUS_IMAGES = {}.tap do |h|
    %w(inactive building failure success).each do |status|
      image = NSImage.new.initWithContentsOfFile(NSBundle.mainBundle.pathForResource(status, :ofType => 'png'))
      h[:"#{status}"] = image
    end
  end
  
  def initialize
    super
    
    # We want changes to prefs to apply immediately
    NSUserDefaultsController.sharedUserDefaultsController.appliesImmediately = true
    
    self.defaults = NSUserDefaults.standardUserDefaults
    
    defaults.registerDefaults(DEFAULT_VALUES)
            
    bundle = NSBundle.mainBundle
      
    self.status_images = STATUS_IMAGES
  end
    
  def awakeFromNib
    super
        
    # Register super awesome value transformer
    NSValueTransformer.setValueTransformer(NotBlankValueTransformer.new, :forName => 'NotBlankValueTransformer')

    self.status_item = NSStatusBar.systemStatusBar.statusItemWithLength(NSSquareStatusItemLength).tap do |s|
      s.menu          = status_menu
      s.highlightMode = true
      s.image         = status_images[:inactive]
    end
    
    observe defaults, :key_path => 'auto_launch' do |old_value, new_value|
      self.auto_launch = new_value
    end
    
    observe projects_controller, :key_path => 'content' do
      self.timer || schedule_timer
    end
    
    observe projects_controller, :key_path => 'arrangedObjects' do |old, new|
      project_updated!
    end
    
    observe projects_controller, :key_path => 'arrangedObjects.status' do |old, new|
      project_updated!
    end
    
    observe projects_controller, :key_path => 'arrangedObjects.enabled' { project_updated! }
    
    self.uri_schemes = %w(http:// https://) # Yes, I'm aware of how ghetto this is.
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
  
  def show_projects_window(sender)
    self.projects_window.makeKeyAndOrderFront self
    NSApp.activateIgnoringOtherApps true
  end
  
  def all_projects
    projects_controller.arrangedObjects
  end
  
  def ping_ci(sender)
    NSLog("Pinging CI")
    
    all_projects.each do |project|
      NSLog("updating project:")
      NSLog(project.description)
      
      project.update! self
    end
  end
  
  def project_updated!
    projects = all_projects.select(&:enabled?)
        
    self.status =
      if projects.all? { |p| p.status.to_s == 'success' }
        :success
      elsif projects.any? { |p| p.status.to_s == 'failure' }
        :failure
      elsif projects.any? { |p| p.status.to_s == 'building' }
        :building
      else
        :inactive
      end
  end
  
  def trigger_build(sender)
    CIJoeProject.post
    ping_ci(self)
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
