require 'thor'

module FindbugsTranslateCheckstyleFormat
  class CLI < Thor
    include ::FindbugsTranslateCheckstyleFormat::Translate
    desc 'translate', 'Exec Translate'
    option :data
    option :file
    def translate
      data = fetch_data(options)
      xml = parse(data)
      checkstyle = trans(xml)
      checkstyle.write(STDOUT, 2)
    end

    no_commands do
      def fetch_data(options)
        data = \
          if options[:data]
            options[:data]
          elsif options[:file]
            File.read(options[:file])
          elsif !$stdin.tty?
            ARGV.clear
            ARGF.read
          end

        fail NoInputError if !data || data.empty?

        data
      end
    end
  end
end
