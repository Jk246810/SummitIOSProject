# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'SummitUIAppNew' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'Firebase'
  pod 'FirebaseAnalytics'
  pod 'FirebaseFirestore'
  pod 'FirebaseAuth'
  pod 'FirebaseMessaging'
  pod 'Swinject'

  # Pods for SummitUIAppNew
 

  target 'SummitUIAppNew WatchKit AppTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'SummitUIAppNew WatchKit AppUITests' do
    # Pods for testing
  end

  target 'SummitUIAppNewTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'SummitUIAppNewUITests' do
    # Pods for testing
  end

end

target 'SummitUIAppNew WatchKit App' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SummitUIAppNew WatchKit App


end

target 'SummitUIAppNew WatchKit Extension' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  #pod 'FirebaseAuth'
  
  # Pods for SummitUIAppNew WatchKit Extension

end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end
