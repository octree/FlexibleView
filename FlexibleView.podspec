Pod::Spec.new do |s|
  s.name             = "FlexibleView"
  s.version          = "1.0.0"
  s.summary          = "Flexible View."
  s.homepage         = "http://github.com/octree/FlexibleView"
  s.license          = 'MIT'
  s.author           = { "Octree" => "fouljz@gmail.com" }
  s.source           = { :git => "https://github.com/octree/FlexibleView.git", :tag => s.version.to_s, :submodules => true}

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.5'
  s.requires_arc = true

  s.source_files = 'Sources/FlexibleView/**/*.{swift}'
  s.ios.frameworks = 'UIKit'
end
