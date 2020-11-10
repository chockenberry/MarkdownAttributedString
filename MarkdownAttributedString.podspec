Pod::Spec.new do |s|
  s.name = 'MarkdownAttributedString'
  s.version = '0.1'
  s.license = 'MIT'
  s.author = 'Craig Hockenberry'
  s.summary = 'Adding Markdown support to NSAttributedString'
  s.homepage = 'https://github.com/chockenberry/MarkdownAttributedString'
  s.source = { :git => 'https://github.com/chockenberry/MarkdownAttributedString.git', :tag => s.version }

  s.ios.deployment_target = '11.0'
  s.tvos.deployment_target = '11.0'
  s.macos.deployment_target = '10.14'
  s.watchos.deployment_target = '4.0'

  s.source_files = 'Sources/NSAttributedString+Markdown.{h,m}'
end
