#
#  array_selection_transformer.rb
#  CobraMenu
#
#  Created by Leigh Caplan on 4/17/11.
#  Copyright 2011 Onehub, Inc. All rights reserved.
#

class ArraySelectionTransformer < NSValueTransformer
  def transformedValue(value)
    value != NSNoSelectionMarker
  end
end

