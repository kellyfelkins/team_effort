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
        line.must_match(/^\d+$/)
      end
    end

    it 'exits when a child process fails' do
      data = [8, 4, 2, 0, 4, 8]

      err = -> {
        $stderr = File.open('/dev/null', 'w')
        begin
          TeamEffort.work(data, 1) do |item|
            16 / item
          end
        ensure
          $stderr.close
          $stderr = STDERR
        end
      }.must_raise RuntimeError
      err.message.must_match /TeamEffort child process failed when processing > 0 </
    end

    it 'invokes an optional proc when it completes an item' do
      data = %w|one two three|
      proc_data = []
      proc = ->(item_index, max_items) { proc_data << [item_index, max_items] }
      TeamEffort.work(data, 1, progress_proc: proc) {}

      proc_data.must_equal [
                             [1, 3],
                             [2, 3],
                             [3, 3],
                           ]
    end

    it 'ignores other child process completions' do
      output_io_class = Class.new do
        def initialize
          @mutex = Mutex.new
          @io = Tempfile.new('mumble')
        end

        def log(text)
          @mutex.synchronize do
            @io.puts text
            @io.flush
          end
        end

        def lines
          @io.rewind
          @io.read.split(/\n/)
        end
      end

      output_io = output_io_class.new

      require 'socket'

      unmanaged_child_reader, unmanaged_child_writer = Socket.pair(:UNIX, :DGRAM, 0)
      maxlen = 1000

      fork do
        output_io.log "unmanaged starting"
        unmanaged_child_writer.close
        output_io.log "unmanaged waiting for IO"
        message = unmanaged_child_reader.recv(maxlen)
        output_io.log "unmanaged received >#{message}< and exiting"
        output_io.log "unmanaged finishing"
      end

      sleep 1

      TeamEffort.work([1, 2], 1) do |index|
        output_io.log "task #{index} starting"
        unmanaged_child_reader.close
        if index == 1
          output_io.log "task 1 waking unmanaged process"
          unmanaged_child_writer.send("wake up", 0)
          unmanaged_child_writer.close
          sleep 1
        end
        output_io.log "task #{index} finishing"
      end

      lines = output_io.lines

      lines.must_equal [
                         'unmanaged starting',
                         'unmanaged waiting for IO',
                         'task 1 starting',
                         'task 1 waking unmanaged process',
                         'unmanaged received >wake up< and exiting',
                         'unmanaged finishing',
                         'task 1 finishing',
                         'task 2 starting',
                         'task 2 finishing',
                       ]
    end
  end
end