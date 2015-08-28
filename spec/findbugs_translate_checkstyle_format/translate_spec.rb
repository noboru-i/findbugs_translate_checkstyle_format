require 'spec_helper'

describe FindbugsTranslateCheckstyleFormat::Translate do
  include FindbugsTranslateCheckstyleFormat::Translate

  describe 'trans' do
    context 'no BugInstance' do
      xml = {
        'BugCollection' => {
          'Project' => {
            'SrcDir' => 'test_dir'
          }
        }
      }
      subject(:doc) { trans(xml) }
      it 'return blank dom' do
        expect(doc.get_elements('/checkstyle/error')).to be_empty
        expect(doc.get_elements('/checkstyle/file').first.attribute('name').value).to eq('test_dir')
      end
    end
    context 'one BugInstance' do
      xml = {
        'BugCollection' => {
          'BugInstance' => {
            'SourceLine' => {
              '@classname' => 'com.example.Test',
              '@start' => 12
            }
          }
        }
      }
      before {
        allow(self).to receive(:fqcn_to_path).and_return('test.java')
      }
      subject(:doc) { trans(xml) }
      it 'return blank dom' do
        expect(doc.get_elements('/checkstyle/error')).to be_empty
        expect(doc.get_elements('/checkstyle/file').first.attribute('name').value).to eq('test.java')
      end
    end
  end

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
