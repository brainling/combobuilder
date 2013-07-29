require 'rspec'
require 'combobuilder'

describe ComboBuilder::Parser do

  before :each do
    @marvel_scheme = ComboBuilder::MarvelInputScheme.new
    @ssf4_scheme = ComboBuilder::StreetFighterInputScheme.new
  end

  describe 'parse input' do

    it 'should parse modified button' do
      nodes = ComboBuilder::Parser.parse(@marvel_scheme, 'cr.h')
      nodes.length.should == 1
      nodes[0].type.should == :sequence
      nodes[0].modifier.should == 'cr'
      nodes[0].parts[0].should == 'h'
    end

    it 'should return error for unknown modifier' do
      nodes = ComboBuilder::Parser.parse(@marvel_scheme, 'foo.h')
      nodes[0].type.should == :error
    end

    it 'should return error for unknown button' do
      nodes = ComboBuilder::Parser.parse(@marvel_scheme, 'cr.foo')
      nodes[0].type.should == :error
    end

    it 'should parse unmodified button' do
      nodes = ComboBuilder::Parser.parse(@marvel_scheme, 'hm')
      nodes[0].type.should == :sequence
      nodes[0].parts[0].should == 'h'
      nodes[0].parts[1].should == 'm'
    end

    it 'should parse multibutton sequence' do
      nodes = ComboBuilder::Parser.parse(@marvel_scheme, 'hs lmh')
      nodes.length.should == 2
      nodes.all? { |n| n.type.should == :sequence }
    end

    it 'should parse multibutton sequence with modifiers' do
      nodes = ComboBuilder::Parser.parse(@marvel_scheme, 'cr.hs lmh')
      nodes.length.should == 2
      nodes.all? { |n| n.type.should == :sequence }
      nodes[0].has_modifier?.should be_true
    end

  end

end
