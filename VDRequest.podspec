Pod::Spec.new do |s|
    s.name         = 'VDRequest'
    s.version      = '1.0.0'
    s.summary      = 'An easy way to send request and upload file'
    s.homepage     = 'https://github.com/VolientDuan/VDRequest'
    s.license      = 'MIT'
    s.authors      = {'volientDuan' => 'volientduan@163.com'}
    s.platform     = :ios, '8.0'
    s.source       = {:git => 'https://github.com/VolientDuan/VDRequest.git', :tag => s.version}
    s.source_files = 'VDRequest/RequestTool/*.{h,m}'
    s.requires_arc = true
end