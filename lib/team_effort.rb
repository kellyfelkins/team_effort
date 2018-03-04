require_relative "team_effort/version"

module TeamEffort
  def self.work(enumerable, max_process_count = 4, progress_proc: nil)
    pids = []
    max_count = enumerable.count
    completed_count = 0

    enumerable.each do |args|
      while pids.size == max_process_count
        finished_pid = Process.wait
        pids.delete finished_pid
        progress_proc.call(completed_count += 1, max_count) if progress_proc
      end

      pids << fork do
        yield args
      end
    end

    while !pids.empty?
      finished_pid = Process.wait
      pids.delete finished_pid
      progress_proc.call(completed_count += 1, max_count) if progress_proc
    end
  end
end
