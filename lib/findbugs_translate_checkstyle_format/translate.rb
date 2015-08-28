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
      if xml['BugCollection']['BugInstance'].blank?
        set_dummy(xml, checkstyle)
        return doc
      end

      bugInstances = xml['BugCollection']['BugInstance'].is_a?(Array) ? xml['BugCollection']['BugInstance'] : [xml['BugCollection']['BugInstance']]
      bugInstances.each do |bugInstance|
        file = checkstyle.add_element("file", {
          'name' => fqcn_to_path(bugInstance['SourceLine']['@classname'], xml)
          })
        file.add_element("error", {
          'line' => bugInstance['SourceLine']['@start'],
          'severity' => '',
          'message' => "[#{bugInstance['@category']}] #{bugInstance['LongMessage']}"
          })
      end

      doc
    end

    def fqcn_to_path(fqcn, xml)
      path = fqcn.gsub('.', '/') + '.java'
      src_dirs = xml['BugCollection']['Project']['SrcDir']
      unless src_dirs.is_a?(Array)
        src_dirs = [src_dirs]
      end
      src_dirs.find do |src|
        src.index(path) != nil
      end
    end

    def set_dummy(xml, checkstyle)
      dummy_src_dir = xml['BugCollection']['Project']['SrcDir']
      dummy_src_dir = dummy_src_dir.first if dummy_src_dir.is_a?(Array)

      checkstyle.add_element("file", {
        'name' => dummy_src_dir
        })

      checkstyle
    end
  end
end
