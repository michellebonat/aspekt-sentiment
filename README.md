# Aspekt-sentiment [![Gem Version](https://badge.fury.io/rb/aspekt-sentiment.svg)](http://badge.fury.io/rb/aspekt-sentiment) [![Build Status](https://travis-ci.org/IllegalCactus/aspekt-sentiment.svg?branch=master)](https://travis-ci.org/IllegalCactus/aspekt-sentiment)

A gem that provides simple aspect-level sentiment analysis, using a dictionary and list of keywords.

**Aspekt** is intended to be lightweight and highly-customisable. You can use the default dictionary or provide your own for whatever domain you are working with, changing the sentiment values as you see fit.

The default list of keywords has been tailored for movie reviews and is provided as an example. You will most likely need to change it to match your specific domain.

While this gem is far from 100% accurate and shouldn't be used in serious NLP applications, it should provide decent results for the average project where some extra information about sentiment could be of value or interest.

**Aspekt** is based on some of the underlying tools from [Rescore](https://github.com/charlieegan3/rescore).

## Installation

	$ gem install aspekt-sentiment

## Usage

### Analyzing text

Given a dictionary:

```yml
good: 1
bad: -1
```

and a list of keywords:

```yml
vision:
  graphics: 100

editing:
  effects: 35

plot:
  story: 100
  dialogue: 60
```

You can use Aspekt to analyze some text:

```ruby
require 'aspekt-sentiment'
analyzer = Aspekt.new

# Check the sentiment value for a word.
analyzer.lookup_sentiment_value("bad")
#=> -1

# Check what aspect a word matches, and with what confidence.
analyzer.lookup_aspect_value("graphics")
#=> {:aspect=>:vision, :confidence=>80}

# Analyze a text.
analyzer.score("The story was awful. The visual effects and graphics however were great. The plot was boring. The director John Smith did an excellent job.")
#=> [{:text=>"The story was awful.",
#		:sentiment=>-2,
#		:context_tags=>{:plot=>100},
#		:emphasis=>0.0,
#		:context_indices=>{
#			:plot=> {:term=>"story", :indices=>[4]}
#		}
#	},
#	{:text=>"The visual effects and graphics however were great.",
#		:sentiment=>2,
#		:context_tags=>{:editing=>35, :vision=>100},
#		:emphasis=>0.0,
#		:context_indices=>
#		{
#			:editing=>{:term=>"effects", :indices=>[11]},
#			:vision=>{:term=>"graphics", :indices=>[10]}
#		}
#	},
#	{:text=>"The plot was boring.",
#		:sentiment=>-2,
#		:context_tags=>{:plot=>50, :length=>25},
#		:emphasis=>0.0,
#		:context_indices=>
#		{
#			:plot=>{:term=>"plot", :indices=>[4]},
#			:length=>{:term=>"boring", :indices=>[9]}
#		}
#	{:text=>"The director John Smith did an excellent job.",
#		:sentiment=>2,
#	 	:context_tags=>{:cinematography=>80},
#	 	:emphasis=>0.0,
#	 	:context_indices=>
#	  	{
#	  		:cinematography=>{:term=>"director", :indices=>[4]}
#	  	},
#	 	:people_tags=>["John Smith"],
#	 	:people_indices=>{"John Smith"=>[13]}}
#	}]
```

### Adding custom dictionaries/keywords/people

**Aspekt-sentiment** currently only supports YAML for the dictionary and aspect keywords files.

```ruby
analyzer.load_dictionary('my_dict.yml') # load a custom dictionary.
analyzer.load_aspect_keywords('my_keywords.yml') # load custom aspect keywords.
analyzer.people << "John Smith" # or analyzer.people += ["John Smith", "John Doe"]

# The analyzer object is now using your custom data for the scoring.
analyzer.score("Lorem Ipsum...")
```

## Contributing

1. Fork it ( https://github.com/IllegalCactus/aspekt-sentiment/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Todo

* Provide support for additional dictionary/aspect file formats.

* Port over the 'people' modules from [Rescore](https://github.com/charlieegan3/rescore).
