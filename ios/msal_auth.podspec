#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint msal_auth.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'msal_auth'
  s.version          = '2.0.2'
  s.summary          = 'A new Flutter plugin for Azure AD authentication.'
  s.description      = <<-DESC
A new Flutter plugin for Azure AD authentication.
                       DESC
  s.homepage         = 'https://www.aubergine.co'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Aubergine Solutions Pvt. Ltd.' => 'flutterdev@aubergine.co' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '14.0'
  s.dependency 'MSAL', '~> 1.7.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
