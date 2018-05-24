class EslintJunitFailure
  attr_accessor :line, :severity, :message, :file_path

  def initialize(failure:, path: Dir.pwd)
    self.file_path = failure.parent.parent.attributes['name'].value.gsub("#{path}/", '')
    self.message = failure.attributes['message'].value
    failure_text_match = failure_text_regex.match(failure.text)
    self.line = failure_text_match[1].to_i
    self.severity = failure_text_match[3]
  end

private

  def failure_text_regex
    /line (\d+), col (\d+), (Error|Warning) - (.*)/
  end

end
