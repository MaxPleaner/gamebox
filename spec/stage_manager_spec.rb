require File.join(File.dirname(__FILE__),'helper')

describe StageManager do
  class FooStage; end
  class BarStage; end

  subject { StageManager.new resource_manager: :resource_manager,
    config_manager: config_manager,
    actor_factory: actor_factory,
    input_manager: input_manager,
    sound_manager: :sound_manager
  }
  let(:actor_factory) { stub('actor_factory', :stage_manager= => nil) }
  let(:input_manager) { stub('input_manager', clear_hooks: nil) }
  let(:config_manager) { stub('config_manager', load_config: stage_config) }

  let(:foo_stage) { stub('foo stage', when: nil, curtain_raising: nil, curtain_dropping: nil) }
  let(:bar_stage) { stub('bar stage', when: nil, curtain_raising: nil, curtain_dropping: nil) }
  let(:foo_stage_config) { {foo: {thing:1} } }
  let(:bar_stage_config) { {bar: {thing:2} } }
  let(:stage_config) { {stages: [foo_stage_config, bar_stage_config]} }
  before do
    Backstage.stubs(:new).returns :backstage
    FooStage.stubs(:new).with(input_manager, actor_factory, 
                                :resource_manager, :sound_manager, 
                                config_manager, :backstage, {thing:1}).
                                returns(foo_stage)
    BarStage.stubs(:new).returns(bar_stage)
  end

  describe '#setup' do
    it 'constructs' do
      subject.should be
    end

    it 'setups the backstage' do
      subject.backstage.should == :backstage
    end

    it 'installs its self on the actor factor' do
      actor_factory.expects(:stage_manager=).with(instance_of(StageManager))
      subject
    end

    it 'sets up the stage config' do
      subject.stage_names.should == [:foo, :bar]
      subject.stage_opts.should == [{thing:1}, {thing:2}]
    end
  end

  describe "#switch_to_stage" do

    it 'activates the new stage' do
      subject.switch_to_stage :foo, :args
      subject.current_stage.should == foo_stage
    end

    it 'raises the curtain on the new stage' do
      foo_stage.expects(:curtain_raising).with(:args)
      subject.switch_to_stage :foo, :args
    end

    it 'shutdowns the current stage' do
      foo_stage.expects(:curtain_dropping).with(:other_args)
      input_manager.expects(:clear_hooks).with(foo_stage)
      subject.switch_to_stage :foo, :args
      subject.switch_to_stage :bar, :other_args
    end
  end

  describe '#prev_stage' do
    it 'should go to prev stage' do
      subject.switch_to_stage :bar
      foo_stage.expects(:curtain_raising).with(:args)

      subject.prev_stage :args
      subject.current_stage.should == foo_stage
    end

    it 'should exit on prev_stage of first stage' do
      subject.switch_to_stage :foo
      lambda { subject.prev_stage :args }.should raise_exception(SystemExit)
    end
  end

  describe '#next_stage' do
    it 'should go to next stage' do
      subject.switch_to_stage :foo
      bar_stage.expects(:curtain_raising).with(:args)

      subject.next_stage :args
      subject.current_stage.should == bar_stage
    end

    it 'should exit on next_stage of last stage' do
      subject.switch_to_stage :bar
      lambda { subject.next_stage :args }.should raise_exception(SystemExit)
    end
  end

  describe '#restart_stage' do
    it 'should restart the current stage' do
      subject.switch_to_stage :foo, :args

      foo_stage.expects(:curtain_raising).with(:other_args)
      subject.restart_stage :other_args
    end
  end

  describe 'callbacks' do
    it 'registers next_stage'
    it 'registers prev_stage'
    it 'registers restart_stage'
    it 'registers change_stage'
  end
end
