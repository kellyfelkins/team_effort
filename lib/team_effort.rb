require "team_effort/version"

module TeamEffort
  def self.work(enumerable, max_process_count = 4)
    pids = []

    enumerable.each do |args|
      if pids.size == max_process_count
        finished_pid = Process.wait
        pids.delete finished_pid
      end

      pids << fork do
        yield args
      end
    end

    while !pids.empty?
      finished_pid = Process.wait
      pids.delete finished_pid
    end
  end
end