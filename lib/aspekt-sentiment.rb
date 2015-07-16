require "aspekt-sentiment/version"
require_relative "analyzer"

module Aspekt
  def self.new
    return Aspekt::Analyzer.new
  end
end
