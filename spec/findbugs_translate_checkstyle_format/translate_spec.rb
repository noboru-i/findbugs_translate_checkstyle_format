require 'spec_helper'

describe FindbugsTranslateCheckstyleFormat::Translate do
  include FindbugsTranslateCheckstyleFormat::Translate

  describe 'fqcn_to_path' do
    fqcn = 'com.example.Test'
    context 'one SrdCir' do
      it 'contains xml' do
        xml = {
          'BugCollection' => {
            'Project' => {
              'SrcDir' => '/test/com/example/Test.java'
            }
          }
        }
        expect(fqcn_to_path(fqcn, xml)).to eq '/test/com/example/Test.java'
      end
    end

    context 'many SrdCir' do
      it 'contains xml array' do
        xml = {
          'BugCollection' => {
            'Project' => {
              'SrcDir' => [
                '/test/com/example/Hoge.java',
                '/test/com/example/Test.java'
              ]
            }
          }
        }
        expect(fqcn_to_path(fqcn, xml)).to eq '/test/com/example/Test.java'
      end
    end
  end
end
