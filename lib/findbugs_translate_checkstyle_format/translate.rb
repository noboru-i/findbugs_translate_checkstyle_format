require 'nori'
require 'rexml/document'

module FindbugsTranslateCheckstyleFormat
  module Translate
    def parse(xml)
      Nori
        .new(parser: :rexml)
        .parse(xml)
    end

    def trans(xml)
      doc = REXML::Document.new
      doc << REXML::XMLDecl.new('1.0', 'UTF-8')

      checkstyle = doc.add_element('checkstyle')
      bug_instances = xml['BugCollection']['BugInstance']
      if bug_instances.blank?
        FindbugsTranslateCheckstyleFormat::Translate.set_dummy(xml, checkstyle)
        return doc
      end

      bug_instances = [bug_instances] if bug_instances.is_a?(Hash)
      bug_instances.each do |bug_instance|
        source_lines =
          if bug_instance.key?('SourceLine')
            bug_instance['SourceLine']
          elsif bug_instance['Class'].is_a?(Array)
            bug_instance['Class'].map { |classes| classes['SourceLine'] }
          else
            bug_instance['Class']['SourceLine']
          end
        source_lines = [source_lines] if source_lines.is_a?(Hash)
        source_lines.each do |source_line|
          file = checkstyle.add_element('file',
                                        'name' => FindbugsTranslateCheckstyleFormat::Translate.fqcn_to_path(source_line['@classname'], xml)
                                       )
          file.add_element('error',
                           'line' => source_line['@start'],
                           'severity' => 'error',
                           'message' => FindbugsTranslateCheckstyleFormat::Translate.create_message(bug_instance)
                          )
        end
      end

      doc
    end

    def self.fqcn_to_path(fqcn, xml)
      path = fqcn.tr('.', '/').gsub(/\$[A-z0-9]+/, '') + '.java'
      src_dirs = xml['BugCollection']['Project']['SrcDir']

      # if find 1 SrcDir, that is single parent dir.
      return src_dirs + '/' + path unless src_dirs.is_a?(Array)

      src_dirs.find { |src| !src.index(path).nil? }
    end

    def self.set_dummy(xml, checkstyle)
      dummy_src_dir = xml['BugCollection']['Project']['SrcDir']
      dummy_src_dir = dummy_src_dir.first if dummy_src_dir.is_a?(Array)

      checkstyle.add_element('file',
                             'name' => dummy_src_dir
                            )

      checkstyle
    end

    def self.create_message(bug_instance)
      link = "http://findbugs.sourceforge.net/bugDescriptions.html##{bug_instance['@type']}"
      "[#{bug_instance['@category']}][#{bug_instance['@type']}] #{bug_instance['LongMessage']}\n#{link}"
    end
  end
end
