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
    submenu = []
    
    submenu << NSMenuItem.alloc.initWithTitle('Update', action: 'update!:', keyEquivalent: '')
    submenu << NSMenuItem.alloc.initWithTitle('Build', action: 'trigger_build:', keyEquivalent: '')
    submenu << NSMenuItem.alloc.initWithTitle('View In Browser', action: 'open_in_browser:', keyEquivalent: '')
    
    menu   = NSMenu.new.tap { |m| m.autoenablesItems = false }
    
    submenu.each_with_index do |item, i|
      item.target = project
      menu.insertItem item, atIndex: i
    end
    
    self.setSubmenu menu
    self.hidden = !project.enabled?
    
    observe project, :key_path => 'status' do |old, new|
      self.status = new
    end
    
    observe project, :key_path => 'name' do |old, new|
      self.title = new
    end
    
    observe project, :key_path => 'enabled' do |old, enabled|
      self.hidden = !enabled
    end
    
    self
  end
  
  def status=(status)
    self.image = ApplicationController::STATUS_IMAGES[(project.status || 'inactive').to_sym]
  end
end