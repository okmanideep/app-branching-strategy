#!usr/bin/env ruby

##
# Usage: ruby update_version.rb ../version.txt --only-patch --dry-run

require 'optparse'
require 'time'

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

# Regex to match the version string in the file
version_regex = /version: (\d{2})(\d{2})\.(\d{2})\.(\d+)\+(\d+)/

def modify_version_line(match, only_patch: false)
  yy = match[1]
  mm = match[2]
  dd = match[3]
  n = Integer(match[4])
  build_number = Integer(match[5])
  puts "Current Version Name: #{yy}#{mm}.#{dd}.#{n}"
  puts "Current Build Number: #{build_number}"

  current_version_without_patch = "#{yy}#{mm}.#{dd}"
  expected_version_without_patch = Time.now.strftime('%y%m.%d')
  update_only_patch = only_patch || expected_version_without_patch == current_version_without_patch

  # always increase the build number
  modified_build_number = build_number + 1

  modified_version_name =
    if update_only_patch
      "#{yy}#{mm}.#{dd}.#{n + 1}" # increase just patch version
    else
      "#{expected_version_without_patch}.0" # use the expected version with 0 patch number
    end

  puts "Modified Version Name: #{modified_version_name}"
  puts "Modified Build Number: #{modified_build_number}"

  "version: #{modified_version_name}+#{modified_build_number}"
end

contents = []
# Read the file
File.open(file_path, 'r') do |file|
  file.each_line do |line|
    match = line.match(version_regex)
    # Extract and print the version name and number if the line matches the regex
    if match
      modified_version_line = modify_version_line(match, only_patch: options[:only_patch])

      if options[:dry_run]
        contents.push(line)
      else
        contents.push(modified_version_line)
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
