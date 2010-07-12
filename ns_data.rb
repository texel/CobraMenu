#
#  ns_data.rb
#  CobraMenu
#
#  Created by Leigh Caplan on 7/3/10.
#  Copyright (c) 2010 Onehub, Inc. All rights reserved.
#

class NSData
  def to_s(encoding = NSUTF8StringEncoding)
    NSString.alloc.initWithData self, encoding:encoding
  end
end