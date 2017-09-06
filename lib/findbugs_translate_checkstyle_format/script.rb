module FindbugsTranslateCheckstyleFormat
  class Script
    extend ::FindbugsTranslateCheckstyleFormat::Translate
    def self.translate(xml_text)
      trans(parse(xml_text)).to_s
    end
  end
end
