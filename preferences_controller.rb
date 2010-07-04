#
#  preferences_controller.rb
#  CobraMenu
#
#  Created by Leigh Caplan on 7/3/10.
#  Copyright (c) 2010 Onehub, Inc. All rights reserved.
#

class PreferencesController < NSWindowController
  attr_accessor :defaults, :url_field, :defaults_controller
  
  def initialize 
    super
    
    self.defaults = defaults_controller.defaults
  end
  
  def save_prefs(sender = self)
    defaults_controller.save self
    window.performClose self
    
    application_controller = NSApplication.sharedApplication.delegate
    
    application_controller.schedule_timer unless application_controller.timer
  end
end
