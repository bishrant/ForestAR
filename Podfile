# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'


target 'dashboard' do
  # Comment the next line if you don't want to use dynamic frameworks
  source 'https://github.com/CocoaPods/Specs.git'
  use_frameworks!
  pod 'SQLite.swift', '~> 0.12.0'
  pod 'SwiftyGif'
  pod 'moa', '~> 12.0'
  pod 'Auk', '~> 11.0'
  pod 'Elephant'
  pod 'XLActionController'
  pod 'XLActionController/Spotify'
  # Pods for dashboard

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
            config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
            config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
        end
    end
 end
