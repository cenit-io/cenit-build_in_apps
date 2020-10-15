require_relative 'lib/cenit/build_in_apps/version'

Gem::Specification.new do |spec|
  spec.name          = "cenit-build_in_apps"
  spec.version       = Cenit::BuildInApps.version
  spec.authors       = ["Maikel Arcia"]
  spec.email         = ["mac@cenit.io"]

  spec.summary       = %q{Support for Cenit Build-In Apps.}
  spec.description   = %q{Basic functionality to create a build-in app for Cenit.}
  spec.homepage      = "https://cenit.io"
  spec.license       = "MIT"
end
