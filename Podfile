#source 'https://github.com/CocoaPods/Specs.git'
source 'https://cdn.jsdelivr.net/cocoa/'

platform :ios, '10.0'
use_frameworks!

#def shared_pods
#  pod 'SQLite.swift'
#end

target 'TimeManager' do
#    supports_swift_versions '> 4.0', '<= 5.0'
    pod 'Charts'
    pod 'RxSwift'
    pod 'RxCocoa'
    pod 'CoreGPX'
    pod 'Cache'
    pod 'SQLite.swift'
    pod 'Mapbox-iOS-SDK'
    pod 'Kanna'
    pod 'Upsurge'
    #    pod 'SwiftLocation'
    #    pod 'LocoKit/LocalStore'
    #XML
    #    pod 'Ono'
    #    supports_swift_versions '> 4.0', '< 5.0'
#    pod 'LocoKit'
    pod 'LocoKit', :git => 'https://github.com/sobri909/LocoKit.git', :branch => 'develop'
    pod 'LocoKit/Timelines', :git => 'https://github.com/sobri909/LocoKit.git', :branch => 'develop'
    pod 'LocoKitCore', :git => 'https://github.com/sobri909/LocoKit.git', :branch => 'develop'

end

target 'TimeManager_Widget' do
    pod 'SQLite.swift'
end

#post_install do |installer|
#  installer.pods_project.targets.each do |target|
#    if ['GRDB','LocoKit'].include? target.name
#      target.build_configurations.each do |config|
#        config.build_settings['SWIFT_VERSION'] = '4.2'
#      end
#    end
#  end
#end


