#!usr/bin/env ruby

##
# Usage ruby print_version.rb ../version.txt --exclude-patch
#

require 'optparse'
require_relative './version'

file_path = ARGV[0]

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage print_version.rb <path> [options]'

  opts.on('-p', '--exclude-patch', 'Exclude patch number') do |p|
    options[:exclude_patch] = p
  end
end.parse!

File.open(file_path, 'r') do |file|
  file.each_line do |line|
    version = Line.new(line).parse

    if version
      puts version.version_name(options[:exclude_patch])
      break
    end
  end
end
