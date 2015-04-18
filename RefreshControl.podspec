Pod::Spec.new do |s|
  s.name         = "RefreshControl"
  s.version      = "1.7"
  s.summary      = "RefreshControl is an useful pull to refresh control for ios developer"

  s.description  = <<-DESC
					pull to refresh trigger refresh mode is divided into traditional and
					automatically trigger refresh mode, the new model allows users to feel the
					presence of the control, enhance the user experience
                   DESC

  s.homepage     = "https://github.com/showmecode/RefreshControl"
  s.license      = "MIT"
  s.author             = { "Moch" => "atcuan@gmail.com" }
  s.social_media_url   = "https://twitter.com/MochXiao"
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/showmecode/RefreshControl.git",
:tag => "1.7" }
  s.requires_arc = true
  s.source_files  = "RefreshControl/RefreshControl/*"
  s.frameworks = 'Foundation', 'UIKit'
end
