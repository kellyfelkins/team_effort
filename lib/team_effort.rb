require_relative "team_effort/version"

module TeamEffort
  def self.work(enumerable, max_process_count = 4)
    total = enumerable.count
    pids = []

    enumerable.each_with_index do |args, index|
      while pids.size == max_process_count
        finished_pid = Process.wait
        delete_pid(pids, finished_pid)
      end

      pids << [fork { yield args }, Time.now]
      item = index + 1
      puts "TE started:#{pids.last} ##{item} of #{total} (#{(item.to_f / total.to_f * 100).round(1)}%)"
    end

    while !pids.empty?
      finished_pid = Process.wait
      delete_pid(pids, finished_pid)
    end
  end

  def self.delete_pid(pids, pid)
    pids.delete_if do |p, t|
      if p == pid
        puts "TE finished:#{pid} in #{(Time.now - t).round(1)} seconds"
        true
      end
    end
  end
end
