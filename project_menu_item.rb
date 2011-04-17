#
#  project_menu.rb
#  CobraMenu
#
#  Created by Leigh Caplan on 4/13/11.
#  Copyright 2011 Onehub, Inc. All rights reserved.
#

class ProjectMenuItem < NSMenuItem
  include Observer
  
  attr_accessor :name, :project, :submenu
  
  def init_with_project project
    self.project = project
    
    self.initWithTitle project.name, action: nil, keyEquivalent: ''
    
    self.status = project.status
    
    # Build up a new submenu
    update = NSMenuItem.alloc.initWithTitle 'Update', action: 'update!:', keyEquivalent: ''
    view   = NSMenuItem.alloc.initWithTitle 'View In Browser', action: 'open_in_browser:', keyEquivalent: ''
    
    menu   = NSMenu.new.tap { |m| m.autoenablesItems = false }
    
    update.target = project
    view.target   = project
        
    menu.insertItem update, atIndex: 0
    menu.insertItem view, atIndex: 1
    
    self.setSubmenu menu
    
    observe project, :key_path => 'status' do |old, new|
      self.status = new
    end
    
    self
  end
  
  def status=(status)
    self.image = ApplicationController::STATUS_IMAGES[(project.status || 'inactive').to_sym]
  end
end