require File.expand_path('../test_helper', __FILE__)

module Larva
  class WorkerPoolTest < Minitest::Test
    def test_should_complete_for_no_processors
      WorkerPool.start({})
    end

    def test_process_logs_start_and_end_messages
      Propono.config.logger.stubs(:info)
      Propono.config.logger.expects(:info).with("Starting 0 threads.")
      Propono.config.logger.expects(:info).with("0 threads started.")
      WorkerPool.start({})
    end

    def test_start_worker_logs_exception
      Larva::Listener.expects(:listen).raises(RuntimeError)
      Propono.config.logger.expects(:error).with do |error|
        error.start_with?("Unexpected listener termination:")
      end
      Propono.config.logger.expects(:error).with('Listener for qux was dead')
      Propono.config.logger.expects(:error).with('Some threads have died:')
      WorkerPool.start({'qux' => nil})
    end

    def test_listen_is_called_correctly
      topic_name = "Foo"
      processor = mock
      Larva::Listener.expects(:listen).with(topic_name, processor)
      WorkerPool.start({topic_name => processor})
    end
  end
end
