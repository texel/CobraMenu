#
#  preferences_controller.rb
#  CobraMenu
#
#  Created by Leigh Caplan on 7/3/10.
#  Copyright (c) 2010 Onehub, Inc. All rights reserved.
#

class PreferencesController < NSWindowController
  attr_accessor :defaults, :url_field, :defaults_controller, :defaults_controller
  
  def awakeFromNib
    self.defaults_controller = NSUserDefaultsController.sharedUserDefaultsController
  end
  
  def save_prefs(sender)
    defaults_controller.save self
    defaults = NSUserDefaults.standardUserDefaults
    
    window.performClose self
    
    application_controller = NSApplication.sharedApplication.delegate
    
    application_controller.schedule_timer
  end
end
