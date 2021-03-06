#
# Be sure to run `pod lib lint GDDataDrivenView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GDDataDrivenView'
  s.version          = '0.8.0'
  s.summary          = '????????? iOS ?????.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
????????? iOS ?????, ??????: Model?View?Presenter ??????; ??????; ???????????
                       DESC

  s.homepage         = 'https://github.com/goodow/GDDataDrivenView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Larry Tin' => 'dev@goodow.com' }
  s.source           = { :git => 'https://github.com/goodow/GDDataDrivenView.git', :tag => "v#{s.version.to_s}" }
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

  s.subspec 'RenderPresenter' do |sp|
    sp.dependency 'GDDataDrivenView/MVP'
    sp.dependency 'GDChannel', '~> 0.8'
    sp.source_files = 'GDDataDrivenView/Classes/RenderPresenter/**/*', 'GDDataDrivenView/Classes/Renders/**/*'
  end

  s.subspec 'ViewControllerPresenter' do |sp|
    sp.dependency 'GDDataDrivenView/MVP'
    sp.dependency 'GDDataDrivenView/Generated'
    sp.dependency 'Aspects', '~> 1.4.1'

    sp.source_files = 'GDDataDrivenView/Classes/ViewControllerPresenter/**/*'
  end

  s.subspec 'Generated' do |sp|
    sp.dependency 'Protobuf', '~> 3.0'

    sp.requires_arc = false
    sp.source_files = 'GDDataDrivenView/Generated/**/*'
  end

  s.subspec 'Model' do |sp|
    sp.source_files = 'GDDataDrivenView/Classes/Model/**/*', 'GDDataDrivenView/Classes/Service/**/*'
  end
end
