#
# Be sure to run `pod lib lint RDXVM.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CombineViewModel'
  s.version          = '0.3.0'
  s.summary          = 'Another ViewModel implementation in Swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
CombineViewModel is Combine version of RDXVM
                       DESC

  s.homepage         = 'https://github.com/skyofdwarf/CombineViewModel'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'skyofdwarf' => 'skyofdwarf@gmail.com' }
  s.source           = { :git => 'https://github.com/skyofdwarf/CombineViewModel.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'
  s.swift_version = '5'

  s.source_files = 'Sources/CombineViewModel/**/*'
  
  # s.resource_bundles = {
  #   'CombineViewModel' => ['CombineViewModel/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'RxSwift', '~> 6.5'
end
