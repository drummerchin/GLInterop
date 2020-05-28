#
# Be sure to run `pod lib lint GLInterop.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GLInterop'
  s.version          = '1.3.2'
  s.summary          = 'A library of GL interoperable texture.'
  s.description      = <<-DESC
A library that supports interoperable render target between GL texture and CVPixelBufferRef and it also applies to Metal texture and CVPixelBufferRef.
DESC

  s.homepage         = 'https://github.com/Qin Hong/GLInterop'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Qin Hong' => 'qinhong@face2d.com' }
  s.source           = { :git => 'https://github.com/Qin Hong/GLInterop.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Source/Classes/**/*'
  s.private_header_files = 'Source/Classes/Private/**/*.h'
  s.requires_arc = 'Source/Classes/**/*{.m,.mm}'
  s.frameworks = 'Foundation', 'UIKit', 'OpenGLES', 'CoreVideo', 'CoreGraphics', 'Metal'
  
end
