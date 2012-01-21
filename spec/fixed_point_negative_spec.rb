require 'spec_helper'

describe FixedPoint do

it "Negative Integers -1 " do
  format = FixedPoint::Format.new(1,4,0)
  fixt   = FixedPoint::Number.new(-1.0, format, "_")

  fixt.source.should   == -1.0
  fixt.to_f.should     == -1.0
  fixt.to_i.should     == -1
  fixt.frac.should == 0.0
  fixt.to_h.should     == "f"
  fixt.to_b.should     == "1111"
end

it "Negative Integers -2 " do
  format = FixedPoint::Format.new(1,4,0)
  fixt   = FixedPoint::Number.new(-2.0, format, "_")

  fixt.source.should   == -2.0
  fixt.to_f.should     == -2.0
  fixt.to_i.should     == -2
  fixt.frac.should     == 0.0
  fixt.to_h.should     == "e"
  fixt.to_b.should     == "1110"
end

it "Negative Integers -1.5 " do
  format = FixedPoint::Format.new(1,4,4)
  fixt   = FixedPoint::Number.new(-1.5, format, "_")

  fixt.source.should   == -1.5
  fixt.to_f.should     == -1.5
  fixt.to_i.should     == -1
  fixt.frac.should     == -0.5
  fixt.to_h.should     == "e8"
  fixt.to_b.should     == "1110_1000"
end
it "Negative Integers -2.25 " do
  format = FixedPoint::Format.new(1,4,4)
  fixt   = FixedPoint::Number.new(-2.25, format, "_")

  fixt.source.should   == -2.25
  fixt.to_f.should     == -2.25
  fixt.to_i.should     == -2
  fixt.frac.should     == -0.25
  fixt.to_h.should     == "dc"
  fixt.to_b.should     == "1101_1100"
end

end
