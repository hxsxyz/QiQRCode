Pod::Spec.new do |s|

  s.name         = "QiQRCode"
  s.version      = "0.0.1"
  s.summary      = "一个轻量级的扫描二维码/条形码，生成二维码/条形码的库"

  s.description  = <<-DESC
                      一个轻量级的扫描二维码/条形码，生成二维码/条形码的库，可以快速实现扫码功能
                      DESC

  s.homepage     = "https://github.com/QiShare/QiQRCode"

  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  s.author             = { "huangxianshuai" => "huangxianshuai@360.cn" }
  # Or just: s.author    = "huangxianshuai"
  # s.authors            = { "huangxianshuai" => "huangxianshuai@360.cn" }
  # s.social_media_url   = "http://twitter.com/huangxianshuai"

  s.platform     = :ios
  s.platform     = :ios, "8.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"

  s.source = { :git => "https://github.com/QiShare/QiQRCode.git", :tag => "#{s.version}" }

  s.source_files  = "QiQRCode/QiCodeReader/**/*.{h,m}"
  # s.exclude_files = "Classes/Exclude"
  # s.public_header_files = "Classes/**/*.h"

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"

  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
