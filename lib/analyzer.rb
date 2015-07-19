require_relative 'utils'
require_relative 'dict/aspects'
require_relative 'dict/dictionary_words'
require 'punkt-segmenter'
require 'yaml'

module Aspekt
  class Analyzer
    attr_accessor :dictionary, :aspect_keywords, :people

    def initialize
      @dictionary = Dictionary::DICTIONARY.clone
      @aspect_keywords = Aspects::ASPECTS.clone
      @people = []
      @prev_name = nil
    end

    def score(text)
      scored_sentences = []

      tokenized_text = punkt_extract_sentences(text)
      tokenized_text.each do |original_sentence|
        sentence = {text: original_sentence, sentiment: 0, context_tags: {}, emphasis: 0}
        clean_text = original_sentence.downcase.split(/\W*\s+\W*/).join(" ").strip

        sentence[:sentiment] = evaluate_sentence(clean_text)
        sentence[:context_tags] = tag_sentence(clean_text)
        sentence[:context_indices] = context_indices(clean_text)
        sentence[:people_tags], sentence[:people_indices] = tag_people(sentence[:text])
        sentence[:emphasis] = count_emphasis(sentence[:text])

        scored_sentences << sentence
      end

      return scored_sentences
    end

    def punkt_extract_sentences(text)
      tokenizer = Punkt::SentenceTokenizer.new(text)
      sentences = tokenizer.sentences_from_text(text, :output => :sentences_text)
      return sentences
    end

    def evaluate_sentence(sentence)
      score = 0
      sentence.split(/\W+/).each do |word|
        score += @dictionary[word] if @dictionary.has_key?(word)
      end
      score = 2 if score > 2
      score = -2 if score < -2
      return score
    end

    def tag_sentence(sentence)
      sentence_tags = Hash.new([])

      @aspect_keywords.each do |context, terms|
        terms.keys.each do |term|
          sentence_tags[context] += [terms[term]] if sentence.match(/(\W|\A)#{term}(\W|\z)/)
        end
      end

      sentence_tags.map { |k, v| sentence_tags[k] = v.reduce(:+) / sentence_tags.size }
      return sentence_tags
    end

    def context_indices(sentence)
      indices = Hash.new{}

      @aspect_keywords.each do |context, terms|
        terms.keys.each do |term|
          if sentence.match(/(\W|\A)#{term}(\W|\z)/)
            indices[context] = {term: term, indices: Utils::get_indexes(sentence, term)}
          end
        end
      end

      return indices
    end

    def tag_people(sentence)
      mentioned_people = [] # The names detected in this sentence.
      people_indexes = Hash.new([]) # where in the sentence the person is mentioned.

      # Tag people in sentence.
      @people.each do |person|
        if sentence.include?(person)
          people_indexes[person] = Utils.get_indexes(sentence.dup, person)
          mentioned_people.push(person)
        end
      end

      # Check for mentions using pronouns.
      if mentioned_people.empty? && @prev_name != nil
        pronouns = ['he', 'him', 'his', 'she', 'her']
          sentence.downcase.gsub(/\W/, ' ').split(/\s+/).each do |word|
            if pronouns.include?(word)
              mentioned_people.push(@prev_name)
              break
            end
          end
      else # If there were people mentioned, update the previous name.
        @prev_name = mentioned_people.last
      end

      return mentioned_people.uniq, people_indexes
    end

    def count_emphasis(sentence)
      words = sentence.split(' ')
      emphasis_counts = 0

      words.each do |word|
        exclems = word.count('?') + word.count('!')
        emphasis_counts += exclems if exclems <= 3
        emphasis_counts += 3 if exclems > 3
        emphasis_counts += 1 if word.gsub(/\W+/, '').match(/[A-Z][A-Z0-9]+/)
        emphasis_counts += 1 if word.include?('**')
        emphasis_counts += 1 if word.include?('<em>')
        emphasis_counts += 1 if word.include?('<strong>')
        emphasis_counts += 1 if word.include?('<b>')
        emphasis_counts += 1 if word.include?('<i>')
        emphasis_counts += 1 if word.include?('very')
        emphasis_counts += 1 if word.include?('extremely')
        emphasis_counts += 1 if word.include?('highly')
        emphasis_counts += 1 if word.include?('complete')
        emphasis_counts += 1 if word.include?('utter')
        emphasis_counts += 1 if word.include?('really')
        emphasis_counts += 1 if word.include?('much')
        emphasis_counts += 1 if word.include?('more')
        emphasis_counts += 1 if word.include?('truly')
        emphasis_counts += 1 if word.include?('such')
        emphasis_counts += 1 if word.include?('total')
        emphasis_counts += 1 if word.include?('totally')
      end

      return emphasis_counts.to_f.round(2)
    end

    def lookup_sentiment_value(word)
      return @dictionary[word] || 0
    end

    def lookup_aspect_value(word)
      @aspect_keywords.each do |aspect, keywords|
        keywords.each do |keyword, confidence|
          if word == keyword
            return {aspect: aspect, confidence: confidence}
          end
        end
      end
      return 0
    end

    def load_aspects(path)
      @aspect_keywords = {}
      aspects_file = YAML.load_file(path)
      aspects_file.each do |aspect, keywords|
        if @aspect_keywords[aspect].nil?
          @aspect_keywords[aspect] = {}
        end
        keywords.each do |aspect_keyword, confidence_level|
          @aspect_keywords[aspect][aspect_keyword] = confidence_level
        end
      end
    end

    def load_dictionary(path)
      @dictionary = {}
      dictionary_file = YAML.load_file(path)
      dictionary_file.each do |word, value|
        @dictionary[word] = value
      end
    end

  end
end
