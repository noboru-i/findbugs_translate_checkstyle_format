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
      else
        set_dummy(xml, checkstyle)
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
      # create dummy
      dummy_src_dir = xml['BugCollection']['Project']['SrcDir']
      if dummy_src_dir.is_a?(Array)
        dummy_src_dir = dummy_src_dir.first
      end
      file = checkstyle.add_element("file", {
        'name' => dummy_src_dir
        })
      checkstyle
    end
  end
end
