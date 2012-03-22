#!/usr/bin/env ruby

require 'bundler/setup'
require 'yajl'
require 'set'

def self.array_average(array)
  array.inject(:+) / array.count
end

cities = {}

File.read('geonames_data/US.txt').lines.each do |line|
  fields = line.split("\t")
  city = fields[2]
  state_abbreviation = fields[4]
  latitude = fields[9].to_f
  longitude = fields[10].to_f

  name = "#{city}, #{state_abbreviation}"
  cities[name] ||= []
  cities[name].push([latitude, longitude])
end

# Reduce all lat/long arrays to a single averaged value.
cities.each do |k, v|
  latitude = array_average(v.map { |ll| ll[0] })
  longitude = array_average(v.map { |ll| ll[1] })
  cities[k] = [latitude, longitude]
end

File.open('cities_US.json', 'w') do |f|
  Yajl::Encoder.encode(cities.to_a, f)
end
