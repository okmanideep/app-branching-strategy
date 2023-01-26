#!usr/bin/env ruby

##
# Usage: ruby update_version.rb ../version.txt --only-patch --dry-run

require 'optparse'
require 'time'
require_relative './version'

file_path = ARGV[0]

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage update_version.rb <path> [options]'

  opts.on('-p', '--only-patch', 'Update only patch number') do |p|
    options[:only_patch] = p
  end

  opts.on('--dry-run', 'Dry run') do |d|
    options[:dry_run] = d
  end
end.parse!

contents = []
# Read the file
File.open(file_path, 'r') do |file|
  file.each_line do |line|
    version = Line.new(line).parse
    # Extract and print the version name and number if the line matches the regex
    if version
      updated_version_line = version.updated_version_line(options[:only_patch])
      puts "current version #{line}"
      puts "modified version #{updated_version_line}"

      if options[:dry_run]
        contents.push(line)
      else
        contents.push(updated_version_line)
      end
    else
      contents.push(line)
    end
  end
end

File.open(file_path, 'w') do |file|
  file.write(contents.join("\n"))
  file.close
end
