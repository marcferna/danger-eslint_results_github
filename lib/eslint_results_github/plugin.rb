module Danger
  # This is your plugin class. Any attributes or methods you expose here will
  # be available from within your Dangerfile.
  #
  # To be published on the Danger plugins site, you will need to have
  # the public interface documented. Danger uses [YARD](http://yardoc.org/)
  # for generating documentation from your plugin source, and you can verify
  # by running `danger plugins lint` or `bundle exec rake spec`.
  #
  # You should replace these comments with a public description of your library.
  #
  # @example Process the eslint results sending inline comments to the Githup PR
  #
  #          eslint_results_github.results_path = 'path/to/results'
  #          eslint_results_github.process
  #
  # @see  Marc Fernandez/danger-eslint_results_github
  # @tags eslint, inline, javascript
  #
  class DangerEslintResultsGithub < Plugin

    # Path to your json formatted eslint results
    #
    # @return   [String]
    attr_accessor :results_path

    # Process the eslint results from the path specified and sends inline
    # comments to the Github PR
    #
    # @return  [void]
    #
    def process
      return if results_path.nil?
      modified_files_results.map { |result| send_comment(result) }
    end

  private

    # Send comment with Danger's warn or fail method.
    #
    # @return [void]
    #
    def send_comment(result)
      result['messages'].each do |result_message|
        filename = result['filePath'].gsub("#{Dir.pwd}/", '')
        method = result_message['severity'] > 1 ? 'fail' : 'warn'
        send(method, result_message['message'], file: filename, line: result_message['line'])
      end
    end

    def modified_files
      @modified_files ||= (
        git.modified_files - git.deleted_files
      ) + git.added_files
    end

    def modified_files_results
      JSON.parse(open(results_path).read)
        .select { |result| modified_files.include?(result['filePath'].gsub("#{Dir.pwd}/", '')) }
        .reject { |result| result['messages'].length.zero? }
        .reject { |result| result['messages'].first['message'].include? 'matching ignore pattern' }
    end
  end
end
