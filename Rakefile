require "rubygems"
require "rake"

require "choctop"

ChocTop::Configuration.new do |s|
  # Remote upload target (set host if not same as Info.plist['SUFeedURL'])
  s.host     = 'dl.cobramenu.onehub.com'
  s.remote_dir = '/path/to/upload/root/of/app'
  
  s.build_target = 'Embed'

  # Custom DMG
  s.background_file = "backing.jpg"
  s.app_icon_position = [120, 225]
  s.applications_icon_position =  [388, 225]
  # s.volume_icon = "dmg.icns"
  # s.applications_icon = "appicon.icns" # or "appicon.png"
end
