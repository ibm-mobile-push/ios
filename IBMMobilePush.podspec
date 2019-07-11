#
# Be sure to run `pod lib lint IBMMobilePush.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "IBMMobilePush"
  s.version          = "3.7.1.4.1"
  s.summary          = "Integration for IBM Mobile Push Notification"
  s.description      = <<-DESC
                       Marketers use customer data and individual behaviors collected from a variety of sources to inform and drive real-time personalized customer interactions with IBM Marketing Cloud. You can use IBM Mobile Push Notification with IBM Marketing Cloud to allow marketers to send mobile app push notifications along with their customer interactions. By implementing the SDKs into your mobile app, you can send push notifications to your users based on criteria such as location, date, events, and more.
                       DESC
  s.homepage         = "https://developer.ibm.com/push/"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'IBM'
  s.author           = { "Jeremy Buchman" => "buchmanj@us.ibm.com" }
  s.source           = { :git => "git@github.com:ibm-mobile-push/ios.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.vendored_frameworks = 'IBMMobilePush.framework'
  
  # s.library = 'sqlite3'
  # s.frameworks = 'CoreTelephony', 'CoreData', 'CoreLocation'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.dependency 'AFNetworking', '~> 2.3'

  # s.resources = ["MceConfig.json"]

end
