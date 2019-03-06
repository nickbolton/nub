Pod::Spec.new do |s|

  s.name         = "Nub"
  s.version      = "0.0.16"
  s.summary      = "Nub Foundation Library"

  s.description  = <<-DESC
                   Nub Foundation Library
                   DESC

  s.homepage     = "https://github.com/nickbolton/nub"
  s.license      = "MIT"

  s.authors = { "Nick Bolton" => "nick@pixeol.com" }
#  s.social_media_url = ""

#  s.documentation_url = ""

  s.ios.deployment_target = "11.0"
  s.osx.deployment_target = "10.11"

  s.source = { :git => "https://github.com/nickbolton/nub.git", :branch => "master" }

  s.subspec "Core" do |s|
    s.source_files = "Source/Core/**/*"
    s.exclude_files = "**/Info*.plist"
  end

  s.subspec "Animator" do |s|
    s.ios.source_files = "Source/Animator/**/*.{swift,m,h}"
    s.dependency "Nub/Core"
    s.exclude_files = "**/Info*.plist"
    s.ios.resources = "Source/**/*.xib"
  end

  s.subspec "Bootstrap" do |s|
    s.ios.source_files = "Source/Bootstrap/**/*.{swift,m,h}"
    s.dependency "Nub/Core"
    s.dependency "Nub/Theme"
    s.exclude_files = "**/Info*.plist"
    s.ios.resources = "Source/**/*.xib"
  end

  s.subspec "Locker" do |s|
    s.ios.source_files = "Source/Locker/**/*.{swift,m,h}"
    s.dependency "Nub/Core"
    s.dependency "FXKeychain", "~> 1.5"
    s.exclude_files = "**/Info*.plist"
    s.ios.resources = "Source/**/*.xib"
  end

  s.subspec "Localize" do |s|
    s.ios.source_files = "Source/Localize/**/*.{swift,m,h}"
    s.dependency "Nub/Core"
    s.dependency "Nub/Theme"
    s.exclude_files = "**/Info*.plist"
    s.ios.resources = "Source/**/*.xib"
  end

  s.subspec "Logger" do |s|
    s.ios.source_files = "Source/Logger/**/*.{swift,m,h}"
    s.dependency "Nub/Core"
    s.dependency "SwiftyBeaver", "~> 1.4"
    s.exclude_files = "**/Info*.plist"
    s.ios.resources = "Source/**/*.xib"
  end

  s.subspec "Api" do |s|
    s.ios.source_files = "Source/Api/**/*.{swift,m,h}"
    s.dependency "Nub/Core"
    s.dependency "Siesta", "~> 1.4"
    s.dependency "Elevate", "~> 3.0"
    s.dependency "ReachabilitySwift", "~> 4.1"
    s.exclude_files = "**/Info*.plist"
    s.ios.resources = "Source/**/*.xib"
  end

  s.subspec "Theme" do |s|
    s.ios.source_files = "Source/Theme/**/*.{swift,m,h}"
    s.dependency "Nub/Core"
    s.exclude_files = "**/Info*.plist"
    s.ios.resources = "Source/**/*.xib"
  end

  s.subspec "View" do |s|
    s.ios.source_files = "Source/View/**/*.{swift,m,h}"
    s.dependency "Nub/Theme"
    s.dependency "SnapKit", "~> 4.0"
    s.exclude_files = "**/Info*.plist"
    s.ios.resources = "Source/**/*.xib"
  end

  s.subspec "ViewController" do |s|
    s.ios.source_files = "Source/ViewController/**/*.{swift,m,h}"
    s.dependency "Nub/Core"
    s.dependency "Nub/Api"
    s.dependency "Nub/View"
    s.dependency "Nub/Logger"
    s.dependency "Nub/Locker"
    s.exclude_files = "**/Info*.plist"
    s.ios.resources = "Source/**/*.xib"
  end

  s.subspec "MVVM" do |s|
    s.ios.source_files = "Source/MVVM/**/*.{swift,m,h}"
    s.dependency "Nub/Core"
    s.exclude_files = "**/Info*.plist"
    s.ios.resources = "Source/**/*.xib"
  end

  s.subspec "Text" do |s|
    s.ios.source_files = "Source/Text/**/*.{swift,m,h}"
    s.dependency "Nub/Core"
    s.dependency "Cache", "~> 4.1"
    s.exclude_files = "**/Info*.plist"
    s.ios.resources = "Source/**/*.xib"
  end

  s.subspec "iOSApplication" do |s|
    s.dependency "Nub/Core"
    s.dependency "Nub/Bootstrap"
    s.dependency "Nub/Locker"
    s.dependency "Nub/Localize"
    s.dependency "Nub/Api"
    s.dependency "Nub/Animator"
    s.dependency "Nub/Text"
    s.dependency "Nub/ViewController"
    s.dependency "Nub/MVVM"
    s.dependency "Nub/Logger"
    s.exclude_files = "**/Info*.plist"
  end

  s.default_subspecs = "Core"
end
