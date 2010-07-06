#
#  keyboard_handler.rb
#  CobraMenu
#
#  Created by Leigh Caplan on 7/5/10.
#  Copyright (c) 2010 Onehub, Inc. All rights reserved.
#

class KeyboardHandler <  NSView

  def initWithFrame(frame)
    super
    return self
  end

  def drawRect(rect)
  end

  def performKeyEquivalent(event)
    action_map = {'x' => 'cut', 'c' => 'copy', 'v' => 'paste', 'a' => 'selectAll'}
    
    if (event.modifierFlags & NSDeviceIndependentModifierFlagsMask) == NSCommandKeyMask
      if action = action_map[event.charactersIgnoringModifiers]
        NSApp.sendAction("#{action}:", :to => self.window.firstResponder(), :from => self)
      end
    else
      super
    end
  end
end
