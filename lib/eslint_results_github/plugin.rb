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
      JSON.parse(open(results_path).read)
        .select { |result| modified_files.include?(result['filePath']) }
        .reject { |result| result['messages'].length.zero? }
        .reject { |result| result['messages'].first['message'].include? 'matching ignore pattern' }
        .map { |result| send_comment(result) }
    end

  private

    # Send comment with Danger's warn or fail method.
    #
    # @return [void]
    #
    def send_comment(result)
      dir = "#{Dir.pwd}/"
      result['messages'].each do |r|
        filename = result['filePath'].gsub(dir, '')
        method = r['severity'] > 1 ? 'fail' : 'warn'
        send(method, r['message'], file: filename, line: r['line'])
      end
    end

    def modified_files
      @modified_files ||= (
        git.modified_files - git.deleted_files
      ) + git.added_files
    end
  end
end
