require_relative "team_effort/version"

module TeamEffort
  def self.work(enumerable, max_process_count = 4, progress_proc: nil)
    pids = []
    arg_sets = []
    previous_proc_result = nil

    max_count = enumerable.count
    completed_count = 0

    enumerable.each do |arg_set|
      while pids.size == max_process_count
        pids, arg_sets, completed_count, previous_proc_result = wait_for_completion(pids, arg_sets, completed_count, max_count, progress_proc, previous_proc_result)
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
      pids, arg_sets, completed_count, previous_proc_result = wait_for_completion(pids, arg_sets, completed_count, max_count, progress_proc, previous_proc_result)
    end
  end

  def self.wait_for_completion(pids, arg_sets, completed_count, max_count, progress_proc, previous_proc_result)
    pid, status = Process.wait2
    pids_index = pids.index(pid)
    if pids_index
      pids.delete_at pids_index
      arg_set = arg_sets.delete_at pids_index
      raise "TeamEffort child process failed when processing > #{arg_set} <" if !status.success?
    end

    if progress_proc
      progress_proc_args = [completed_count += 1, max_count]
      progress_proc_args << previous_proc_result if progress_proc.arity == 3
      proc_result = progress_proc.call(*progress_proc_args)
    end

    [pids, arg_sets, completed_count, proc_result]
  end
end
