#
#  ci_joe_menu.rb
#  CobraMenu
#
#  Created by Leigh Caplan on 4/16/11.
#  Copyright 2011 Onehub, Inc. All rights reserved.
#

class CIJoeMenu < NSMenu
  include Observer
  
  attr_accessor :projects_controller, :menus
  
  def awakeFromNib
    self.menus = {}
    
    observe projects_controller, key_path: 'arrangedObjects' { update_menu }    
  end
  
  def update_menu
    projects_controller.arrangedObjects.each do |project|
      menu = self.menus[project.object_id] ||=
        ProjectMenuItem.alloc.init_with_project(project).tap do |menu|
          self.insertItem menu, atIndex: 0
        end            
    end
  end
end
