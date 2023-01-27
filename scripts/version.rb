class Version
  def initialize(match)
    @yy = match[1]
    @mm = match[2]
    @dd = match[3]
    @n = Integer(match[4])
    @build_number = Integer(match[5])
  end

  def updated_version_line(only_patch)
    current_version_without_patch = "#{@yy}#{@mm}.#{@dd}"
    expected_version_without_patch = Time.now.strftime('%y%m.%d')
    update_only_patch = only_patch || expected_version_without_patch == current_version_without_patch
    # always increase the build number
    modified_build_number = @build_number + 1

    modified_version_name =
      if update_only_patch
        "#{@yy}#{@mm}.#{@dd}.#{@n + 1}" # increase just patch version
      else
        "#{expected_version_without_patch}.0" # use the expected version with 0 patch number
      end

    "version: #{modified_version_name}+#{modified_build_number}\n"
  end

  def version_name(exclude_patch)
    if exclude_patch
      "#{@yy}#{@mm}.#{@dd}"
    else
      "#{@yy}#{@mm}.#{@dd}.#{@n}"
    end
  end
end

##
# Helper class to parse lines from a file that contains version line
class Line
  # Regex to match the version string in the file
  VERSION_REGEX = /^version: (\d{2})(\d{2})\.(\d{2})\.(\d+)\+(\d+)\n$/.freeze

  def initialize(content)
    @content = content
  end

  def parse
    match = VERSION_REGEX.match(@content)

    Version.new(match) if match
  end
end
