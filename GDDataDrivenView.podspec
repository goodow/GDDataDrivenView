#
# Be sure to run `pod lib lint GDDataDrivenView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GDDataDrivenView'
  s.version          = '0.1.0'
  s.summary          = 'A short description of GDDataDrivenView.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/<GITHUB_USERNAME>/GDDataDrivenView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Larry Tin' => 'dev@goodow.com' }
  s.source           = { :git => 'https://github.com/<GITHUB_USERNAME>/GDDataDrivenView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'GDDataDrivenView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'GDDataDrivenView' => ['GDDataDrivenView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'

  s.subspec 'MVP' do |sp|
    sp.source_files = 'GDDataDrivenView/Classes/MVP/**/*'
  end

  s.subspec 'Core' do |sp|
    sp.dependency 'GDDataDrivenView/MVP'
    sp.dependency 'GDChannel', '~> 0.6'
    sp.dependency 'SVPullToRefresh', '~> 0.4'
    sp.source_files = 'GDDataDrivenView/Classes/Model/**/*', 'GDDataDrivenView/Classes/Layout/**/*', 'GDDataDrivenView/Classes/Renders/**/*'
  end

  s.subspec 'UIViewController' do |sp|
    sp.dependency 'GDDataDrivenView/MVP'
    sp.dependency 'GDChannel', '~> 0.6'
    sp.dependency 'Aspects', '~> 1.4.1'

    sp.source_files = 'GDDataDrivenView/Classes/UIViewController/**/*'
    sp.requires_arc = ['GDDataDrivenView/Classes/UIViewController/GDD*', 'GDDataDrivenView/Classes/UIViewController/UIViewController+GDDataDrivenView.*']
  end
end
