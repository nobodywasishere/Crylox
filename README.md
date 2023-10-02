# crylox - crystal lox interpreter

TODO: Write a description here

## Installation

TODO: Write installation instructions here

## Usage

TODO: Write usage instructions here

## Performance

Crystal:

```crystal
def fib(n : Int32)
  if n <= 1
    n
  else
    fib(n - 2) + fib(n - 1)
  end
end

start_time = (Time.utc - Time::UNIX_EPOCH).total_seconds

(0...20).each do |i|
  fib(i)
end

puts (Time.utc - Time::UNIX_EPOCH).total_seconds - start_time
```

```
0.00013566017150878906

real    0m19.314s
user    0m18.572s
sys     0m0.597s
```

Crylox:
```lox
fun fib(n) {
  if (n <= 1) return n;
  fib(n - 2) + fib(n - 1);
}

var start_time = clock();

for (var i = 0; i < 20; i = i + 1) {
  fib(i);
}

print (clock() - start_time);
```

```
0.7572522163391113

real    0m25.466s
user    0m24.641s
sys     0m0.662s
```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/your-github-user/crylox/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Margret Riegert](https://github.com/your-github-user) - creator and maintainer
