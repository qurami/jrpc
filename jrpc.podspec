#
# Be sure to run `pod lib lint jrpc.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'jrpc'
  s.version          = '0.1.1-beta'
  s.summary          = 'JSON-RPC 2.0 Client'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
jrpc is a JSON-RPC 2.0 client written in swift.
for more information about JSON-RPC 2.0 please refer to: http://www.jsonrpc.org/specification
                       DESC

  s.homepage         = 'https://github.com/qurami/jrpc'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Marco Musella' => 'mar.musella@gmail.com' }
  s.source           = { :git => 'https://github.com/qurami/jrpc.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'jrpc/Classes/**/*'

  # s.resource_bundles = {
  #   'jrpc' => ['jrpc/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
