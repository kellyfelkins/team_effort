require 'minitest/autorun'
require_relative '../lib/team_effort'
require 'tempfile'

describe TeamEffort do
  describe '#work' do
    it 'performs work in child processes' do
      mutex = Mutex.new
      output_io = Tempfile.new('mumble')
      output = nil
      begin
        data = %w|one two three|
        TeamEffort.work(data) do |item|
          mutex.synchronize do
            output_io.puts Process.pid
            output_io.flush
          end
        end
        output_io.rewind
        output = output_io.read
      ensure
        output_io.close
        output_io.unlink
      end

      lines = output.split(/\n/)
      lines.size.must_equal 3
      lines.each do |line|
        line.must_match /^\d+$/
      end
    end
  end
end