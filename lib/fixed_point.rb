module FixedPoint
  VERSION = '0.1.0'
end

begin
  require_relative 'fixed_point/format'
  require_relative 'fixed_point/fixdt'
  require_relative 'fixed_point/number'
rescue
  require 'fixed_point/format'
  require 'fixed_point/fixdt'
  require 'fixed_point/number'
end