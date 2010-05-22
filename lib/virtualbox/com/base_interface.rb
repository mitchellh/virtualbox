require 'thread'

module VirtualBox
  module COM
    class BaseInterface
      def initialize
        @task_queue = Queue.new

        @lib_thread = Thread.new(@task_queue) do |queue|
          while true
            task, result = queue.pop

            # Run the task, set the return value, and run the waiter
            # which will simply finish that thread
            result << task.call
          end
        end
      end

      # This function takes a block and runs it on a thread which is
      # guaranteed to be the same since the first time this is
      # called. This is required by the MSCOM implementation and is a
      # good idea in general so that multiple API calls aren't firing
      # at once.
      def on_lib_thread(&task)
        # If we're already on the lib thread, then just run it!
        return task.call if Thread.current == @lib_thread

        # Add the task to the queue
        result = Queue.new
        @task_queue << [task, result]

        # Pop the result off of the result queue
        result.pop
      end
    end
  end
end
