require 'spec_helper'
require 'tempfile'

describe Aspekt do

 before(:each) do
    @analyzer = Aspekt::Analyzer.new
    @analyzer.people << "John Smith"
    @text = "The story was awful! The visual effects and graphics however were great. The plot was boring. The director John Smith did an excellent job."
    @result = @analyzer.score(@text)
  end

  it 'initializes the dictionary and aspect keywords' do
    expect(@analyzer.dictionary).not_to be nil
    expect(@analyzer.aspect_keywords).not_to be nil
  end

  it 'analyzes some text and returns tagged sentences' do
    expect(@result.length).to eq(4)
    expect(@result[0]).not_to be nil
  end

  it 'assigns sentiment appropriately' do
    expect(@result[0][:sentiment]).to be < 0
  end

  it 'detects emphasis' do
    expect(@result[0][:emphasis]).to be > 0
  end

  it 'retrieves a sentiment value correctly' do
    expect(@analyzer.lookup_sentiment_value('bad')).to eq(-2)
  end

  it 'retrieves an aspect value correctly' do
    expect(@analyzer.lookup_aspect_value('color')).to eq({aspect: :vision, confidence: 90})
  end

  it 'finds context indices correctly' do
    expect(@result[0][:context_indices][:plot][:indices]).to eq([4])
  end

  it 'tags relevant people' do
    expect(@result[3][:people_tags]).to eq(["John Smith"])
    expect(@result[3][:people_indices]).to eq({"John Smith"=>[13]})
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

    expect(@analyzer.dictionary["good"]).to eq(1)
    dict.unlink
  end

end
