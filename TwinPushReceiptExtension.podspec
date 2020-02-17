Pod::Spec.new do |s|

  # Meta data
  s.name         = "TwinPushReceiptExtension"
  s.version      = "1.0.2"
  s.summary      = "TwinPushReceiptExtension is a companion library to the TwinPush SDK that adds notification receipts to deliveries sent from TwinPush"
  s.homepage     = "http://twinpush.com"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "TwinCoders" => "info@twincoders.com" }
  s.platform     = :ios, "10.0"
  s.swift_versions = ['4.0', '4.2', '5.0']
  s.source       = { :git => "https://github.com/TwinPush/twinpush-ios-receipt-extension.git", :tag => "v#{s.version}" }

  # Source configuration
  s.source_files  = "TPNotificationReceiptService.swift"
  s.frameworks = "UserNotifications"
  s.requires_arc = true

end