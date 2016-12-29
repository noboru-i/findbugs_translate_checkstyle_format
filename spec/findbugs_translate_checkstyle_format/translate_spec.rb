require 'spec_helper'

describe FindbugsTranslateCheckstyleFormat::Translate do
  include FindbugsTranslateCheckstyleFormat::Translate

  describe 'trans' do
    before do
      allow(FindbugsTranslateCheckstyleFormat::Translate).to receive(:fqcn_to_path).and_return('test.java')
    end
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
        expect(doc.get_elements('/checkstyle/file/error')).to be_empty
        expect(doc.get_elements('/checkstyle/file').first.attribute('name').value).to eq('test_dir')
      end
    end
    context 'single BugInstance' do
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
      subject(:doc) { trans(xml) }
      it 'return blank dom' do
        expect(doc.get_elements('/checkstyle/file/error')).not_to be_empty
        expect(doc.get_elements('/checkstyle/file/error').first.attribute('line').value).to eq('12')
        expect(doc.get_elements('/checkstyle/file/error').first.attribute('message').value).not_to be_nil
        expect(doc.get_elements('/checkstyle/file').first.attribute('name').value).to eq('test.java')
      end
    end
    context 'single BugInstance and many SourceLine' do
      xml = {
        'BugCollection' => {
          'BugInstance' => [
            {
              'SourceLine' => {
                '@classname' => 'com.example.Test',
                '@start' => 12
              },
            },
            {
              'SourceLine' => {
                '@classname' => 'com.example.Test',
                '@start' => 14
              },
            }
          ]
        }
      }
      subject(:doc) { trans(xml) }
      it 'return blank dom' do
        expect(doc.get_elements('/checkstyle/file').count).to eq(2)
        expect(doc.get_elements('/checkstyle/file[1]/error').first.attribute('line').value).to eq('12')
        expect(doc.get_elements('/checkstyle/file[1]/error').first.attribute('message').value).not_to be_nil
        expect(doc.get_elements('/checkstyle/file[2]/error').first.attribute('line').value).to eq('14')
        expect(doc.get_elements('/checkstyle/file[2]/error').first.attribute('message').value).not_to be_nil
        expect(doc.get_elements('/checkstyle/file').first.attribute('name').value).to eq('test.java')
      end
    end
    context 'many BugInstance' do
      xml = {
        'BugCollection' => {
          'BugInstance' => [
            {
              'SourceLine' => {
                '@classname' => 'com.example.Test',
                '@start' => 12
              }
            },
            {
              'SourceLine' => {
                '@classname' => 'com.example.Test2',
                '@start' => 23
              }
            }
          ]
        }
      }
      subject(:doc) { trans(xml) }
      it 'return blank dom' do
        expect(doc.get_elements('/checkstyle/file/error')).not_to be_empty
        expect(doc.get_elements('/checkstyle/file/error')[0].attribute('line').value).to eq('12')
        expect(doc.get_elements('/checkstyle/file/error')[0].attribute('message').value).not_to be_nil
        expect(doc.get_elements('/checkstyle/file/error')[1].attribute('line').value).to eq('23')
        expect(doc.get_elements('/checkstyle/file/error')[1].attribute('message').value).not_to be_nil
        expect(doc.get_elements('/checkstyle/file').first.attribute('name').value).to eq('test.java')
      end
    end
    context 'single BugInstance and SourceLine in many Class' do
      xml = {
        'BugCollection' => {
          'BugInstance' => {
            'Class' => [
              {
                'SourceLine' => {
                  '@classname' => 'com.example.Test',
                  '@start' => 12
                }
              },
              {
                'SourceLine' => {
                  '@classname' => 'com.example.Test',
                  '@start' => 14
                }
              }
            ]
          }
        }
      }
      subject(:doc) { trans(xml) }
      it 'return blank dom' do
        expect(doc.get_elements('/checkstyle/file').count).to eq(2)
        expect(doc.get_elements('/checkstyle/file[1]/error').first.attribute('line').value).to eq('12')
        expect(doc.get_elements('/checkstyle/file[1]/error').first.attribute('message').value).not_to be_nil
        expect(doc.get_elements('/checkstyle/file[2]/error').first.attribute('line').value).to eq('14')
        expect(doc.get_elements('/checkstyle/file[2]/error').first.attribute('message').value).not_to be_nil
        expect(doc.get_elements('/checkstyle/file').first.attribute('name').value).to eq('test.java')
      end
    end
    context 'single BugInstance and SourceLine in single Class' do
      xml = {
        'BugCollection' => {
          'BugInstance' => {
            'Class' => {
              'SourceLine' => {
                '@classname' => 'com.example.Test',
                '@start' => 12
              }
            }
          }
        }
      }
      subject(:doc) { trans(xml) }
      it 'return blank dom' do
        expect(doc.get_elements('/checkstyle/file/error')).not_to be_empty
        expect(doc.get_elements('/checkstyle/file/error')[0].attribute('line').value).to eq('12')
        expect(doc.get_elements('/checkstyle/file/error')[0].attribute('message').value).not_to be_nil
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
              'SrcDir' => '/test'
            }
          }
        }
        expect(FindbugsTranslateCheckstyleFormat::Translate.fqcn_to_path(fqcn, xml)).to eq '/test/com/example/Test.java'
      end
    end

    context 'many SrcDir' do
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
        expect(FindbugsTranslateCheckstyleFormat::Translate.fqcn_to_path(fqcn, xml)).to eq '/test/com/example/Test.java'
      end
    end

    context 'inner class' do
      it 'anonymous inner class' do
        xml = {
          'BugCollection' => {
            'Project' => {
              'SrcDir' => [
                '/test/com/example/Test.java',
                '/test/com/example/Hoge.java'
              ]
            }
          }
        }
        expect(FindbugsTranslateCheckstyleFormat::Translate.fqcn_to_path('com.example.Test$1', xml)).to eq '/test/com/example/Test.java'
      end

      it 'inner class' do
        xml = {
          'BugCollection' => {
            'Project' => {
              'SrcDir' => [
                '/test/com/example/Test.java',
                '/test/com/example/Hoge.java'
              ]
            }
          }
        }
        expect(FindbugsTranslateCheckstyleFormat::Translate.fqcn_to_path('com.example.Test$TestClass', xml)).to eq '/test/com/example/Test.java'
      end

      it 'include number' do
        xml = {
          'BugCollection' => {
            'Project' => {
              'SrcDir' => [
                '/test/com/example/Test.java',
                '/test/com/example123/Test.java'
              ]
            }
          }
        }
        expect(FindbugsTranslateCheckstyleFormat::Translate.fqcn_to_path('com.example123.Test$1', xml)).to eq '/test/com/example123/Test.java'
      end
    end
  end

  describe 'set_dummy' do
    context 'single SrcDir' do
      xml = {
        'BugCollection' => {
          'Project' => {
            'SrcDir' => 'test_dir'
          }
        }
      }
      require 'rexml/document'
      doc = REXML::Document.new
      checkstyle = doc.add_element('checkstyle')
      before { FindbugsTranslateCheckstyleFormat::Translate.set_dummy(xml, checkstyle) }
      it 'return blank dom' do
        expect(doc.get_elements('/checkstyle/file/error')).to be_empty
        expect(doc.get_elements('/checkstyle/file').first.attribute('name').value).to eq('test_dir')
      end
    end
    context 'many SrcDir' do
      xml = {
        'BugCollection' => {
          'Project' => {
            'SrcDir' => %w(test_dir1 test_dir2)
          }
        }
      }
      require 'rexml/document'
      doc = REXML::Document.new
      checkstyle = doc.add_element('checkstyle')
      before { FindbugsTranslateCheckstyleFormat::Translate.set_dummy(xml, checkstyle) }
      it 'return blank dom' do
        expect(doc.get_elements('/checkstyle/file/error')).to be_empty
        expect(doc.get_elements('/checkstyle/file').first.attribute('name').value).to eq('test_dir1')
      end
    end
  end

  describe 'create_message' do
    bug_instance = {
      '@type' => 'RV_EXCEPTION_NOT_THROWN'
    }
    subject(:message) { FindbugsTranslateCheckstyleFormat::Translate.create_message(bug_instance) }
    it 'include link' do
      expect(message).to include('http://findbugs.sourceforge.net/bugDescriptions.html#RV_EXCEPTION_NOT_THROWN')
    end
  end
end
