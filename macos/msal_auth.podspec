#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint msal_auth.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'msal_auth'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin for Azure AD authentication.'
  s.description      = <<-DESC
A new Flutter plugin for Azure AD authentication.
                       DESC
  s.homepage         = 'https://www.auberginesolutions.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Aubergine Solutions Pvt. Ltd.' => 'flutterdev@auberginesolutions.com' }

  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.15'
  s.dependency 'MSAL', '~> 1.6.1'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
