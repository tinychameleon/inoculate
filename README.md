# Inoculate

Inoculate is a small, thread-safe dependency injection library configured entirely with Ruby.
It provides several life-cycles and provides dependency access through private accessors.

[![Gem Version](https://badge.fury.io/rb/inoculate.svg)](https://badge.fury.io/rb/inoculate)

---

## What's in the box?
✅ Simple usage documentation written to get started fast. [Check it out!](#quick-start)

📚 YARD generated API documentation for the library. [Check it out!](https://tinychameleon.github.io/inoculate/)

🤖 RBS types for your type checking wants. [Check it out!](./sig/inoculate.rbs)

💎 Tests against many Ruby versions. [Check it out!](#supported-ruby-versions)

🔒 MFA protection on all gem owners. [Check it out!](https://rubygems.org/gems/inoculate)

---

1. [Quick Start](#quick-start)
2. [Usage](#usage)
   1. [Dependency Life Cycles](#dependency-life-cycles)
      1. [Transient](#transient)
      2. [Instance](#instance)
      3. [Singleton](#singleton)
      4. [Thread Singleton](#thread-singleton)
   2. [Renaming the Declaration API](#renaming-the-declaration-api)
   3. [Hide Your Dependency on Inoculate](#hide-your-dependency-on-inoculate)
3. [Installation](#installation)
   1. [Supported Ruby Versions](#supported-ruby-versions)

## Quick Start
Create an initialization file for your dependencies and start registering them.

```ruby
require "inoculate"

Inoculate.initialize do |config|
  config.transient(:counter) { Counter.new }
end
```

To take advantage of dependency injection in tests, initialize based on the run-time environment.

```ruby
# config/environments/test.rb
require "inoculate"

Inoculate.initialize do |config|
  config.transient(:counter) { instance_double(Counter) }
end
```

Finally, declare your dependencies (which are injected as included modules).

```ruby
require "inoculate"

class HistogramGraph
  include Inoculate::Porter
  inoculate_with :counter

  def to_s
    counter.to_s
  end
end
```

## Usage

### Dependency Life Cycles
#### Transient
Transient dependencies are constructed for each call of the dependency method.

```ruby
class Counter
   attr_reader :count

   def initialize
      @count = 0
   end

   def inc
      @count += 1
   end
end

Inoculate.initialize do |config|
   config.transient(:counter) { Counter.new }
end

class Example
   include Inoculate::Porter
   inoculate_with :counter

   def to_s
      counter.inc
      "Count is: #{counter.count}"
   end
end

a = Example.new
puts a, a, a
```

This results in:

```
Count is: 0
Count is: 0
Count is: 0
=> nil
```

#### Instance
Instance dependencies are constructed once for each instance of a dependent class.

```ruby
class Counter
   attr_reader :count

   def initialize
      @count = 0
   end

   def inc
      @count += 1
   end
end

Inoculate.initialize do |config|
   config.instance(:counter) { Counter.new }
end

class Example
   include Inoculate::Porter
   inoculate_with :counter

   def initialize(name)
      @name = name
   end

   def to_s
      counter.inc
      "[#{@name}] Count is: #{counter.count}"
   end
end

a = Example.new("a")
b = Example.new("b")
puts a, a, b
```

This results in:

```
[a] Count is: 1
[a] Count is: 2
[b] Count is: 1
=> nil
```

#### Singleton
Singleton dependencies are constructed once.

```ruby
class Counter
   attr_reader :count

   def initialize
      @count = 0
   end

   def inc
      @count += 1
   end
end

Inoculate.initialize do |config|
   config.singleton(:counter) { Counter.new }
end

class Example
   include Inoculate::Porter
   inoculate_with :counter

   def initialize(name)
      @name = name
   end

   def to_s
      counter.inc
      "[#{@name}] Count is: #{counter.count}"
   end
end

a = Example.new("a")
b = Example.new("b")
puts a, a, b
```

This results in:

```
[a] Count is: 1
[a] Count is: 2
[b] Count is: 3
=> nil
```

#### Thread Singleton
Thread Singleton dependencies are constructed once for any thread or fiber.

```ruby
class Counter
   attr_reader :count

   def initialize
      @count = 0
   end

   def inc
      @count += 1
   end
end

Inoculate.initialize do |config|
   config.thread_singleton(:counter) { Counter.new }
end

class Example
   include Inoculate::Porter
   inoculate_with :counter

   def initialize(name)
      @name = "Example: #{name}"
   end

   def to_s
      counter.inc
      "[#{@name}] Count is: #{counter.count}"
   end
end

class AnotherExample
   include Inoculate::Porter
   inoculate_with :counter

   def initialize(name)
      @name = "AnotherExample: #{name}"
   end

   def to_s
      5.times { counter.inc }
      "[#{@name}] Count is: #{counter.count}"
   end
end

threads = %w[a b].map do |tag|
   Thread.new(tag) do |t|
      e = Example.new(t)
      a = AnotherExample.new(t)
      puts e, e, a, a
   end
end

threads.each(&:join)
```

This results in:

```
[Example: a] Count is: 1
[Example: b] Count is: 1
[Example: b] Count is: 2
[Example: a] Count is: 2
[AnotherExample: b] Count is: 7
[AnotherExample: a] Count is: 7
[AnotherExample: b] Count is: 12
[AnotherExample: a] Count is: 12
=> [#<Thread:0x000000010d703c68 (irb):177 dead>, #<Thread:0x000000010d703b50 (irb):177 dead>]
```


### Renaming the Declaration API
The `inoculate_with` API is named to avoid immediate collisions with other modules
and code you may have. You can use it as-is, or rename it to something you see fit
for your project.

```ruby
require "inoculate"

class HistogramGraph
  include Inoculate::Porter[:inject]
  inject :counter
end
```

### Hide Your Dependency on Inoculate
Writing `Inocuate::Porter` everywhere in your code is probably going to get old fast,
feel free to hide it behind a base class or common included module.

```ruby
# Make it available to all Rails controllers.
class ApplicationController < ActionController::Base
  include Inoculate::Porter[:dependencies]
end
```

## Installation
Inoculate is a pure ruby library and does not rely on any compiled dependencies.

Install it by adding it to your gemfile and then running `bundle install`

```ruby
gem "inoculate"
```

Or manually install it with `gem`

```shell
$ gem install inoculate
```

### Supported Ruby Versions
Inoculate is tested against the following Ruby versions:

- 3.0
- 3.1
- 3.2
- 3.3.0-preview1

## Development
After checking out the repo:

1. run `bin/setup` to install dependencies.
2. run `rake spec` to run the tests.
3. run `rake spec:all` to run the tests across supported Ruby versions using Docker.
4. run `rake standard` to see lint errors.

You can also run `bin/console` for an interactive prompt that will allow you to experiment.

### Local Installation
Run `bundle exec rake install` or `bundle exec rake install:local`.

### Releasing
1. Update the version number in `lib/inoculate/version.rb`.
2. Run `bundle exec rake yard` to generate the latest documentation.
3. Run `bundle exec rake release` to create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/tinychameleon/inoculate.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
