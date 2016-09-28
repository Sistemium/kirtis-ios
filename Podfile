xcodeproj 'kirtis-ios/kirtis-ios.xcodeproj'

# Uncomment this line to define a global platform for your project
platform :ios, '8.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end

use_frameworks!
pod 'ReachabilitySwift'
pod 'Fabric'
pod 'Crashlytics'

target 'kirtis-ios' do

end

target 'kirtis-iosTests' do

end
