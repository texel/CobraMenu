#
#  not_blank_value_transformer.rb
#  CobraMenu
#
#  Created by Leigh Caplan on 7/13/10.
#  Copyright (c) 2010 Onehub, Inc. All rights reserved.
#

class NotBlankValueTransformer < NSValueTransformer
  def transformedValue(value)
    return false if value.nil?
    
    value.to_s.size >= 1
  end
end
