# TeamEffort

Team Effort is a module that makes it easy to dispatch work to child
processes allowing you to speed processing by taking advantage of
multiple cores.

## Installation

Add this line to your application's Gemfile:

    gem 'team_effort'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install team_effort

## Usage

To do work in child processes just call `TeamEffort.work` with a collection
of items to process and a block:

```ruby
class ProcessALotOfStuff

  def some_method
    # collection = a lot of stuff from somewhere
    TeamEffort.work(collection) do |item|
      # do some work on item
    end
  end
  
end
```

You may specify the number of child processes with the work method:
 
```ruby
def some_method
  # collection = a lot of stuff from somewhere
  TeamEffort.work(collection, 3) do |item| # do the work using 3 child processes
    # do some work on item
  end
end
```

The number of child processes defaults to 4.

The work method will create a new child process for each item in the
enumeration using ruby's Process.fork so there is overhead on each
item processed. Team Effort works best when there is substantial work
to be performed on each item to minimize overhead.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
