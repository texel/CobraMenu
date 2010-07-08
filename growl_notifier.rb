#
#  growl_notifier.rb
#  CobraMenu
#
#  Created by Leigh Caplan on 7/6/10.
#  Copyright (c) 2010 Onehub, Inc. All rights reserved.
#

module GrowlNotifier
  GROWL_PATH = NSBundle.mainBundle.pathForResource('growlnotify', :ofType => '')
  
  def self.post(title, body, sticky)
    `"#{GROWL_PATH}" -H localhost #{"-s" if sticky} -n "CobraMenu" -d "CobraMenu" -t #{title} -m "#{body}"`
  end
  
  def self.post_for_status(status, sticky)
    status_map = {
      :success  => 'Succeeded',
      :failure  => 'Failed',
      :building => 'In Progress',
      :inactive => 'Unavailable'
    }
    
    post('CobraMenu', "Build #{status_map[status]}", sticky)
  end
end
