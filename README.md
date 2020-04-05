# TeamEffort

TeamEffort makes it easy to process a collection with child processes
allowing you to take advantage of multiple cores. By replacing

```ruby
    collection.each do |item|
      # do some work on item
    end
```

with 

```ruby
    TeamEffort.work(collection) do |item|
      # do some work on item
    end
```

you get each item processed in a new child process.

## Installation

Add this line to your application's Gemfile:

    gem 'team_effort'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install team_effort

## Usage

To do work in child processes just call `TeamEffort.work` with a
collection of items to process and a block:

```ruby
    TeamEffort.work(collection) do |item|
      # do some work on item
    end
```

You may specify the number of child processes with the work method:
 
```ruby
    TeamEffort.work(collection, 3) do |item| # do the work using 3 child processes
      # do some work on item
    end
```
The number of child processes defaults to 4.

You can pass in a proc to receive completion notifications.
 
```irb
> data = %w|one two three|
> progress_proc = ->(index, max_index) { puts "#{ sprintf("%3i%", index.to_f / max_index * 100) }" }
> TeamEffort.work(data, 1, progress_proc: progress_proc) {}
 33%
 66%
100%
```

Your proc can return a result that will be provided the next time the proc is called.

```irb
> data = 1..1_000
> progress_proc = ->(index, max_index, previous_percent_complete) {
>   percent_complete = sprintf("%3i%", index.to_f / max_index * 100)
>   if percent_complete != previous_percent_complete # Only print when the percent complete changes
>     puts "#{ percent_complete }"
>   end
>   percent_complete
> }
> TeamEffort.work(data, progress_proc: progress_proc) {}
  0%
  1%
  2%
  3%
...
```
 
In rails you need to reestablish your ActiveRecord connection in the
child process:

```ruby
    ActiveRecord::Base.clear_all_connections!
    begin
      TeamEffort.work(collection, max_process_count) do |item|
    
        ActiveRecord::Base.establish_connection
    
        # do some work with active record
    
      end
    ensure
      ActiveRecord::Base.establish_connection
    end    
```

## Discussion

TeamEffort uses child processes to do concurrent processing. To review
the unix process model I recommend Jesse Storimer's
[Working With Unix Processes][1].
 
[1]: http://www.jstorimer.com/products/working-with-unix-processes

A disadvantage to using child processes for concurrent processing is
the work required to create the child process and the duplication of
memory.  For this reason you should only use TeamEffort on collections
where there is significant processing to be performed on each item.

An advantage of using child processes is that the memory is reclaimed
when the child process goes away. This can make long running jobs
resilient to memory leaks.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
