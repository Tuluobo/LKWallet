# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'
inhibit_all_warnings!
use_frameworks!

target 'LKWallet' do
    pod 'Alamofire', '~> 4.6'
    pod 'SVProgressHUD', '~> 2.2'
    pod 'SnapKit', '~> 4.0.0'
    pod 'ReactiveSwift', '~> 3.1.0'
    pod 'ReactiveCocoa', '~> 7.1.0'
    pod 'MJRefresh', '~> 3.1.15'
    pod 'CryptoSwift', '~> 0.8.3'
    pod 'PopupController', '~> 0.2.0'
    pod 'Geth', '~> 1.8.3'
    pod 'NVActivityIndicatorView', '~> 4.1.1'
    # 统计和广告
    pod 'Google-Mobile-Ads-SDK', '~> 7.29.0'
    pod 'Amplitude-iOS', '~> 4.0.4'
    pod 'Fabric', '~> 1.7.2'
    pod 'Crashlytics', '~> 3.9.3'
    
    target 'LKWalletTests' do
        inherit! :search_paths
        # Pods for testing
    end
    
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if ['PopupController'].include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.2'
            end
        end
    end
end
