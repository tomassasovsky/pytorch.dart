#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint pytorch.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'pytorch_ios'
  s.version          = '0.0.1'
  s.summary          = 'A flutter plugin for pytorch model inference. Supports image models as well as custom models.'
  s.description      = <<-DESC
  A flutter plugin for pytorch model inference. Supports image models as well as custom models.
                       DESC
  s.homepage         = 'http://sportsvisio.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Sports Visio, Inc' => 'tomas@sportsvisio.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  
  s.ios.deployment_target = '12.0'
  s.static_framework = true
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'LibTorch', '~> 1.8.0'
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
      'HEADER_SEARCH_PATHS' => '$(inherited) "${PODS_ROOT}/LibTorch/install/include"'
  }
end
