#
#  blank_value_transformer.rb
#  CobraMenu
#
#  Created by Leigh Caplan on 4/13/11.
#  Copyright 2011 Onehub, Inc. All rights reserved.
#

class BlankValueTransformer < NSValueTransformer
  def transformedValue(value)
    return false if value.nil?
    
    value = value.to_s unless value.is_a?(Array)
    
    value.size == 0
  end
end
