class Version
  def initialize(match)
    @major = match[1]
    @minor = match[2]
    @patch = Integer(match[3])
  end

  def updated_version_line(only_patch)
    current_version_without_patch = "#{@major}.#{@minor}"
    expected_version_without_patch = Time.now.strftime('%y%m.%d') # Ex: 2302.03 (3rd Feb, 2023)
    update_only_patch = only_patch || expected_version_without_patch == current_version_without_patch

    modified_version_name =
      if update_only_patch
        raise StandardError.new("Patch number has reached it's limit - 99") if @patch >= 99

        updated_patch_section = (@patch + 1).to_s.rjust(2, '0')
        "#{@major}.#{@minor}.#{updated_patch_section}" # increase just patch version
      else
        "#{expected_version_without_patch}.00" # use the expected version with 0 patch number
      end

    # strip periods from version name for the build number
    modified_build_number = modified_version_name.gsub('.', '')

    "version: #{modified_version_name}+#{modified_build_number}\n"
  end

  def version_name(exclude_patch = false)
    if exclude_patch
      "#{@major}.#{@minor}"
    else
      "#{@major}.#{@minor}.#{@patch.to_s.rjust(2, '0')}"
    end
  end
end

##
# Helper class to parse lines from a file that contains version line
class Line
  # Regex to match the version string in the file
  VERSION_REGEX = /^version: (\d+)\.(\d+)\.(\d+)\+(\d+)\n$/.freeze

  def initialize(content)
    @content = content
  end

  def parse
    match = VERSION_REGEX.match(@content)

    Version.new(match) if match
  end
end
