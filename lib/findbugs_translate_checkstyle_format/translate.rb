require 'nori'

module FindbugsTranslateCheckstyleFormat
  module Translate
    def parse(xml)
      Nori
        .new(parser: :rexml)
        .parse(xml)
    end

    def trans(xml)
      require 'rexml/document'
      doc = REXML::Document.new
      doc << REXML::XMLDecl.new('1.0', 'UTF-8')

      checkstyle = doc.add_element("checkstyle")
      if xml['BugCollection']['BugInstance']
        xml['BugCollection']['BugInstance'].each do |bugInstance|
          file = checkstyle.add_element("file", {
            'name' => fqcn_to_path(bugInstance['SourceLine']['@classname'], xml)
            })
          file.add_element("error", {
            'line' => bugInstance['SourceLine']['@start'],
            'severity' => '',
            'message' => "[#{bugInstance['@category']}] #{bugInstance['LongMessage']}"
            })
        end
      else
        # create dummy
        dummy_src_dir = xml['BugCollection']['Project']['SrcDir'].first
        file = checkstyle.add_element("file", {
          'name' => dummy_src_dir
          })
      end

      doc
    end

    def fqcn_to_path(fqcn, xml)
      path = fqcn.gsub('.', '/') + '.java'
      xml['BugCollection']['Project']['SrcDir'].find do |src|
        src.index(path) != nil
      end
    end
  end
end
