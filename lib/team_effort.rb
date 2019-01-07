require_relative "team_effort/version"

module TeamEffort
  def self.work(enumerable, max_process_count = 4, progress_proc: nil)
    pids = []
    arg_sets = []

    max_count = enumerable.count
    completed_count = 0

    enumerable.each do |arg_set|
      while pids.size == max_process_count
        pids, arg_sets, completed_count = wait_for_completion(pids, arg_sets, completed_count, max_count, progress_proc)
      end

      pids << fork do
        begin
          yield arg_set
          exit! 0
        rescue => e
          $stderr.puts "TeamEffort child process error"
          $stderr.puts e
          $stderr.puts caller
          exit! 1
        end
      end
      arg_sets << arg_set
    end

    while !pids.empty?
      pids, arg_sets, completed_count = wait_for_completion(pids, arg_sets, completed_count, max_count, progress_proc)
    end
  end

  def self.wait_for_completion(pids, arg_sets, completed_count, max_count, progress_proc)
    pid, status = Process.wait2
    pids_index = pids.index(pid)
    if pids_index
      pids.delete_at pids_index
      arg_set = arg_sets.delete_at pids_index
      raise "TeamEffort child process failed when processing > #{arg_set} <" if !status.success?
    end
    progress_proc.call(completed_count += 1, max_count) if progress_proc
    [pids, arg_sets, completed_count]
  end
end
