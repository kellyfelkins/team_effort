require_relative "team_effort/version"

module TeamEffort
  def self.work(enumerable, max_process_count = 4)
    total = enumerable.count
    pids = []

    enumerable.each_with_index do |args, index|
      while pids.size == max_process_count
        finished_pid = Process.wait
        pids.delete finished_pid
        puts "TE finished:#{finished_pid}"
      end

      pids << fork do
        yield args
      end
      item = index + 1
      puts "TE started:#{pids.last} ##{item} of #{total} (#{(item.to_f / total.to_f * 100).round(2)}%)"
    end

    while !pids.empty?
      finished_pid = Process.wait
      pids.delete finished_pid
    end
  end
end
