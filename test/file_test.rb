# Script file dependency tests for Inprovise
#
# Author::    Martin Corino
# License::   Distributes under the same license as Ruby

require_relative 'test_helper'

describe Inprovise::FileAction do
  before :each do
    @script = Inprovise::Script.new('my-script')
  end

  after :each do
    reset_script_index!
  end

  describe "Inprovise::FileAction::ScriptExt" do
    it 'adds a file dependency' do
      fa = Inprovise::FileAction::ScriptExt.new(@script, {
        source: 'example.txt',
        destination: './remote_example.txt',
      })
      fa.configure
      @script.children.must_equal [fa.script_name]
      fa_script = Inprovise::ScriptIndex.default.get(fa.script_name)
      fa_script.name.must_equal fa.script_name
      fa_script.children.must_equal [fa.script_name('-content')]
      fa_content_script = Inprovise::ScriptIndex.default.get(fa.script_name('-content'))
      fa_content_script.name.must_equal fa.script_name('-content')
    end

    it 'adds a file dependency with permissions' do
      fa = Inprovise::FileAction::ScriptExt.new(@script, {
        source: 'example.txt',
        destination: './remote_example.txt',
        permissions:  0644,
      })
      fa.configure
      @script.children.must_equal [fa.script_name]
      fa_script = Inprovise::ScriptIndex.default.get(fa.script_name)
      fa_script.name.must_equal fa.script_name
      fa_script.children.must_equal [fa.script_name('-content'), fa.script_name('-permissions')]
      fa_content_script = Inprovise::ScriptIndex.default.get(fa.script_name('-content'))
      fa_content_script.name.must_equal fa.script_name('-content')
      fa_permissions_script = Inprovise::ScriptIndex.default.get(fa.script_name('-permissions'))
      fa_permissions_script.name.must_equal fa.script_name('-permissions')
    end

    it 'adds a file dependency with owner' do
      fa = Inprovise::FileAction::ScriptExt.new(@script, {
        source: 'example.txt',
        destination: './remote_example.txt',
        user: 'me',
        group: 'others'
      })
      fa.configure
      @script.children.must_equal [fa.script_name]
      fa_script = Inprovise::ScriptIndex.default.get(fa.script_name)
      fa_script.name.must_equal fa.script_name
      fa_script.children.must_equal [fa.script_name('-content'), fa.script_name('-permissions')]
      fa_content_script = Inprovise::ScriptIndex.default.get(fa.script_name('-content'))
      fa_content_script.name.must_equal fa.script_name('-content')
      fa_permissions_script = Inprovise::ScriptIndex.default.get(fa.script_name('-permissions'))
      fa_permissions_script.name.must_equal fa.script_name('-permissions')
    end
  end

  describe 'DSL:file' do
    it 'adds a file dependency' do
      Inprovise::Script::DSL.new(@script).instance_eval do
        file({
          name: 'example',
          source: 'example.txt',
          destination: './remote_example.txt',
        })

        triggers 'another_script'
      end
      @script.children.must_equal ['file[example]', 'another_script']
      fa_script = Inprovise::ScriptIndex.default.get('file[example]')
      fa_script.name.must_equal 'file[example]'
      fa_script.children.must_equal ['file-content[example]']
      fa_content_script = Inprovise::ScriptIndex.default.get('file-content[example]')
      fa_content_script.name.must_equal 'file-content[example]'
    end
  end

  describe 'applying' do
    before :each do
      @local_file_path = File.join(File.dirname(__FILE__), 'fixtures', 'example.txt')
      @node = Inprovise::Infrastructure::Node.new('myNode', {channel: 'test', helper: 'test'})
      @runner = Inprovise::ScriptRunner.new(@node, @script)
    end

    after :each do
      reset_infrastructure!
    end

    it 'applies a file dependency' do
      Inprovise::Script::DSL.new(@script).instance_eval do
        file({
          name: 'example',
          source: 'example.txt',
          destination: './remote_example.txt',
        })
      end
      @node.helper.expects(:exists?).twice
                  .with('./remote_example.txt')
                  .returns(false, true)
      @node.helper.expects(:upload).once.with() {|from, to| from =~ /example.txt\Z/ && to =~ /\Ainprovise-tmp-/}
      @node.helper.expects(:move).once.with() {|from, to| to == './remote_example.txt' }
      @node.helper.expects(:hash_for).once.with('./remote_example.txt').returns(Digest::SHA1.file(@local_file_path).hexdigest)
      @runner.execute(:apply)
    end

    it 'applies a file dependency with permissions' do
      Inprovise::Script::DSL.new(@script).instance_eval do
        file({
          name: 'example',
          source: 'example.txt',
          destination: './remote_example.txt',
          permissions: 0644
        })
      end
      @node.helper.expects(:exists?).twice
                  .with('./remote_example.txt')
                  .returns(false, true)
      @node.helper.expects(:upload).once.with() {|from, to| from =~ /example.txt\Z/ && to =~ /\Ainprovise-tmp-/}
      @node.helper.expects(:move).once.with() {|from, to| to == './remote_example.txt' }
      @node.helper.expects(:hash_for).once.with('./remote_example.txt').returns(Digest::SHA1.file(@local_file_path).hexdigest)
      @node.helper.expects(:permissions).twice
                  .with('./remote_example.txt')
                  .returns(0, 0644)
      @node.helper.expects(:set_permissions).once.with() {|path, perm| path == './remote_example.txt' && perm == 0644 }
      @runner.execute(:apply)
    end

    it 'applies a file dependency with owner' do
      Inprovise::Script::DSL.new(@script).instance_eval do
        file({
          name: 'example',
          source: 'example.txt',
          destination: './remote_example.txt',
          user: 'me',
          group: 'others'
        })
      end
      @node.helper.expects(:exists?).twice
                  .with('./remote_example.txt')
                  .returns(false, true)
      @node.helper.expects(:upload).once.with() {|from, to| from =~ /example.txt\Z/ && to =~ /\Ainprovise-tmp-/}
      @node.helper.expects(:move).once.with() {|from, to| to == './remote_example.txt' }
      @node.helper.expects(:hash_for).once.with('./remote_example.txt').returns(Digest::SHA1.file(@local_file_path).hexdigest)
      @node.helper.expects(:owner).twice
                  .with('./remote_example.txt')
                  .returns({user: 'him', group: 'them'}, {user: 'me', group: 'others'})
      @node.helper.expects(:set_owner).once.with() {|path, user, group| path == './remote_example.txt' && user == 'me' && group == 'others' }
      @runner.execute(:apply)
    end

    it 'applies a file dependency with blocks' do
      Inprovise::Script::DSL.new(@script).instance_eval do
        file({
          name: 'example',
          source: Proc.new  { config.local_file },
          destination: Proc.new { config.remote_file },
        })
      end
      @node.helper.expects(:exists?).twice
                  .with('./remote_example.txt')
                  .returns(false, true)
      @node.helper.expects(:upload).once.with() {|from, to| from =~ /example.txt\Z/ && to =~ /\Ainprovise-tmp-/}
      @node.helper.expects(:move).once.with() {|from, to| to == './remote_example.txt' }
      @node.helper.expects(:hash_for).once.with('./remote_example.txt').returns(Digest::SHA1.file(@local_file_path).hexdigest)
      @runner.execute(:apply, {local_file: 'example.txt', remote_file: './remote_example.txt'})
    end
  end

  describe 'reverting' do
    before :each do
      @local_file_path = File.join(File.dirname(__FILE__), 'fixtures', 'example.txt')
      @node = Inprovise::Infrastructure::Node.new('myNode', {channel: 'test', helper: 'test'})
      @runner = Inprovise::ScriptRunner.new(@node, @script)
    end

    after :each do
      reset_infrastructure!
    end

    it 'reverts a file dependency' do
      Inprovise::Script::DSL.new(@script).instance_eval do
        file({
          name: 'example-del',
          source: 'example.txt',
          destination: './remote_example.txt',
        })
      end
      @node.helper.expects(:exists?).twice
                  .with('./remote_example.txt')
                  .returns(true, true)
      @node.helper.expects(:hash_for).once.with('./remote_example.txt').returns(Digest::SHA1.file(@local_file_path).hexdigest)
      @node.helper.expects(:delete).once.with('./remote_example.txt')
      @runner.execute(:revert)
    end

  end
end
