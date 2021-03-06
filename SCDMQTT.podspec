#
# Be sure to run `pod lib lint SCDMQTT.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SCDMQTT'
  s.version          = '0.1.0'
  s.summary          = 'A library of MQTT Client.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: A library of MQTT Client.
                       DESC

  s.homepage         = 'https://github.com/jigang-duan/SCDMQTT'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jigang-duan' => 'jigang.duan@tcl.com' }
  s.source           = { :git => 'https://github.com/jigang-duan/SCDMQTT.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'SCDMQTT/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SCDMQTT' => ['SCDMQTT/Assets/*.png']
  # }

  s.public_header_files = 'SCDMQTT/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'CocoaAsyncSocket', '~> 7.6'
end
