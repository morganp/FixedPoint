
NAME="fixed_point"
require File.join( File.dirname(__FILE__), 'lib', NAME )


spec = Gem::Specification.new do |s|
   s.name         = NAME
   s.version      = FixedPoint::VERSION
   s.platform     = Gem::Platform::RUBY
   s.summary      = 'Fixed Point numerical type '
   s.homepage     = "http://amaras-tech.co.uk/software/#{NAME}"
   s.authors      = "Morgan Prior"
   s.email        = "#{NAME}_gem@amaras-tech.co.uk"
   s.description  = %{Fixed Point numerical type for simulating fixed point calculations}
   s.files        = [Dir.glob("LICENSE")]
   s.files        += Dir.glob("README.md")
   s.files        += Dir.glob("HISTORY.md")
   s.files        += Dir.glob("Rakefile")
   s.files        += Dir.glob("examples/*")
   s.files        += Dir.glob("lib/**/*")
   s.files        += Dir.glob("spec/*")
   s.has_rdoc     = false

end

