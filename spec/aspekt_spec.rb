require 'spec_helper'
require 'tempfile'

describe Aspekt do

 before(:each) do
    @analyzer = Aspekt::Analyzer.new
    @result = @analyzer.score("The sound effects were terrible!")
  end

  it 'has a version number' do
    expect(Aspekt::VERSION).not_to be nil
  end

  it 'initializes the dictionary and aspect keywords' do
    expect(@analyzer.dictionary).not_to be nil
    expect(@analyzer.aspect_keywords).not_to be nil
  end

  it 'analyzes some text and returns tagged sentences' do
    expect(@result.length).to eq(1)
    expect(@result[0]).not_to be nil
  end

  it 'assigns sentiment appropriately' do

    expect(@result.length).to eq(1)
    expect(@result[0][:sentiment]).to be < 0
  end

  it 'detects emphasis' do
    expect(@result[0][:emphasis]).to be > 0
  end

  it 'retrieves a sentiment value correctly' do
    expect(@analyzer.lookup_sentiment_value('bad')).to eq(-2)
  end

  it 'retrieves an aspect value correclty' do
    expect(@analyzer.lookup_aspect_value('color')).to eq({aspect: :vision, confidence: 90})
  end

  it 'loads custom aspect keywords' do
    aspect = Tempfile.new('custom_aspects.yml')
    aspect.write("plot:\n story: 70\n dialogue: 50\nvisuals:\n effects: 80\n cgi: 60")
    aspect.close
    @analyzer.load_aspects(aspect.path)

    expect(@analyzer.aspect_keywords["visuals"]["effects"]).to eq(80)
    aspect.unlink
  end

  it 'loads a custom dictionary' do
    dict = Tempfile.new('custom_dict.yml')
    dict.write("good: 1\nbad: -1")
    dict.close
    @analyzer.load_dictionary(dict.path)

    expect(@analyzer.dictionary["good"]).not_to be nil
    dict.unlink
  end

end
