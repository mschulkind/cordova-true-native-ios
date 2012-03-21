#!/usr/bin/env ruby

require 'bundler/setup'
require 'yajl'
require 'set'

cities = Set.new

File.read('geonames_data/US.txt').lines.each do |line|
  fields = line.split("\t")
  city = fields[2]
  state_abbreviation = fields[4]

  cities << "#{city}, #{state_abbreviation}"
end

File.open('cities_US.json', 'w') do |f|
  Yajl::Encoder.encode(cities.to_a, f)
end
