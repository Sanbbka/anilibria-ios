use_frameworks!
inhibit_all_warnings!

target 'Anilibria' do
    #Network
    pod 'Kingfisher', '7.4.1'

    #Utils
    pod 'DITranquillity', '4.3.5'
    pod 'Localize-Swift', '3.1.0'
    pod 'lottie-ios', '3.5.0'
end

post_install do |installer|
  installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
             end
        end
 end
end
