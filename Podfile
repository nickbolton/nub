# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'Nub iOS' do
  use_frameworks!
  pod 'SwiftyBeaver', '~> 1.4'
  pod 'FXKeychain', '~> 1.5'
  pod 'Siesta', '~> 1.4'
  pod 'ReachabilitySwift', '~> 4.1'
  pod 'Cache', '~> 4.1'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'Siesta' || target.name == 'Cache'
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.0'
            end
        end
    end
end
