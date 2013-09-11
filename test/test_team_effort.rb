require "minitest/autorun"
require_relative "../lib/team_effort"

describe TeamEffort do
  describe "#work" do
    it "performs work in a child processes" do
      test_class = Class.new do
        include TeamEffort
        require 'tempfile'

        def do_some_work
          mutex = Mutex.new
          output_io = Tempfile.new('mumble')
          begin
            data = %w|one two three|
            work(data) do |item|
              mutex.synchronize do
                output_io.puts Process.pid
              end
            end
            output_io.rewind
            output = output_io.read
          ensure
            output_io.close
            output_io.unlink
          end
          output
        end
      end

      test = test_class.new
      output = test.do_some_work
      lines = output.split(/\n/)
      lines.size.must_equal 3
      lines.each do |line|
        line.must_match /^\d+$/
      end
    end
  end
end