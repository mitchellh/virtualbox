require 'thread'

module VirtualBox
  module COM
    class BaseInterface
      def initialize
        @mutex = Mutex.new
        @lib_thread = Thread.new do
          while true
            # Stop the thread initially, we'll get woken up manually when we
            # have work to do.
            Thread.stop unless Thread.current[:task]

            # We were woken up! We should have a task. Run it and be done.
            Thread.current[:return] = Thread.current[:task].call if Thread.current[:task]
            Thread.current[:waiter].run if Thread.current[:waiter]
          end
        end
      end

      # This function takes a block and runs it on a thread which is
      # guaranteed to be the same since the first time this is
      # called. This is required by the MSCOM implementation and is a
      # good idea in general so that multiple API calls aren't firing
      # at once.
      def on_lib_thread(&task)
        @mutex.synchronize do
          # Create the completion checking thread which just sleeps.
          waiter = Thread.new { Thread.stop }

          # Set the task and the waiter thread on the worker and start up the
          # worker.
          @lib_thread[:task] = task
          @lib_thread[:waiter] = waiter
          @lib_thread.run

          # Wait on the waiter, which marks completion
          waiter.join

          # Return the return value
          @lib_thread[:return]
        end
      end
    end
  end
end
