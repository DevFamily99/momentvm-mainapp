# Used to migrate templates from leaf 3 to leaf 4
class Parser
  def initialize
    @command_nesting_levels = []
    @full_body = ''
    @processed_body = ''
    @closing_tag = nil
  end

  attr_accessor :command_nesting_levels
  attr_accessor :full_body
  attr_accessor :converted_body
  attr_accessor :last_seen_char
  attr_accessor :processed_body

  # skip html comments and all text in style or script tags
  def read_line(line)
    if @closing_tag
      @closing_tag.nil? if line.include?(@closing_tag)
      return line
    end

    # commented out line
    return line if line.match(/<!--(.*?)/)

    # single line script tag
    return line if line.match(%r{<script[\s\S]*?>[\s\S]*?</script>}i)

    if line.include?('<style>')
      @closing_tag = '</style>'
      return line
    end

    if line.include?('<script')
      @closing_tag = '</script>'
      return line
    end

    parse_vapor(line)
  end

  def parse_vapor(line)
    command_nesting_levels.push('for') if line.include?('#for(')
    command_nesting_levels.push('if') if line.include?('#if(')
    line.gsub!(/}\s*else\s*{/, '#else:')
    line.gsub!(/\)[\s]*{/, '):') # ) {   -> ):
    line.gsub!('}', "#end#{command_nesting_levels.pop}") if line.include?('}')
    line
  end

  def walk
    @processed_body = ''
    @full_body.split("\n").each_with_index do |line, _i|
      @processed_body += read_line(line) + "\n"
    end
  end
end
