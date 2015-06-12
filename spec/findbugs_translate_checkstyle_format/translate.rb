require 'spec_helper'

describe FindbugsTranslateCheckstyleFormat do
  describe 'fqcn_to_path' do
    fqcn = 'com.example.Test'
    context 'one SrdCir' do
      it 'contains xml' do
        xml = {
          'BugCollection' => {
            'Project' => {
              'SrcDir' => {
                '/test/com/exapmle/Test'
              }
            }
          }
        }
        expect(fqcn_to_path(fqcn, xml)).to eq '/test/com/exapmle/Test'
      end
    end

    context 'many SrdCir' do
      it 'contains xml array' do
        xml = {
          'BugCollection' => {
            'Project' => {
              'SrcDir' => [
                '/test/com/exapmle/Hoge'
                '/test/com/exapmle/Test'
              ]
            }
          }
        }
        expect(fqcn_to_path(fqcn, xml)).to eq '/test/com/exapmle/Test'
      end
    end
  end
end
