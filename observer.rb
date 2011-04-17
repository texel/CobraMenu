# observer.rb
# CobraMenu
#
# Created by Leigh Caplan on 7/7/10.
# Copyright 2010 Onehub, Inc. All rights reserved.

module Observer
    
  def observe(object, key_path: key, &block)
    raise ArgumenError, "No object to observe!" unless object
    
    self.observed_objects ||= {}
    
    observed_objects[object.object_id] ||= {}
    
    observed_objects[object.object_id][key] = block
    
    object.addObserver self, forKeyPath: key, options: (NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld), context: nil
  end
  
  # observe defaults, :key_path => 'auto_launch' do |old_value, new_value|
  #   self.auto_launch = new_value
  # end
    
  def observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)    
    if info = observed_objects[object.object_id]
      info.each do |key, proc|        
        if key == keyPath
          instance_exec(change[NSKeyValueChangeOldKey], change[NSKeyValueChangeNewKey], &proc) 
        end
      end
    end
  end
  
  def self.included(target)
    target.send :attr_accessor, :observed_objects
  end
end