# Loise

**A Noise-Generator for LFE**

<img src="resources/images/loise.jpg" />


## Introduction

This is a library, written in [LFE](http://lfe.io/), useful for generating
Perlin and Simplex noise. Perlin noise is a computer-generated visual effect
developed by Ken Perlin, who won an Academy Award for Technical Achievement for
inventing it. It can be used to simulate elements from nature, and is especially
useful in circumstances where computer memory is limited. (See the complete
[Perlin Wikipedia article](http://en.wikipedia.org/wiki/Perlin_noise).)

Simplex noise, on the other hand, is a method for constructing an n-dimensional
noise function comparable to Perlin noise ("classic" noise) but with a lower
computational overhead, especially in larger dimensions. Ken Perlin designed
the algorithm in 2001 to address the limitations of his classic noise
function, especially in higher dimensions. (See the complete
[Simplex Wikipedia article](http://en.wikipedia.org/wiki/Simplex_noise) for
more.)


## Background

This is a port of the
[Racket noise-generator](https://github.com/jpverkamp/noise) by
[jpverkamp](https://github.com/jpverkamp) to LFE.


## Dependencies

This project assumes that you have [rebar](https://github.com/rebar/rebar)
installed somwhere in your ``$PATH``.


## Eye Candy

The data generated with the ``perlin`` and ``simplex`` functions can be used to
create images. Erlang is not a good language for image generation, however this
library does provide some convenience functions for generating images.


### Perlin

Below are 4 perlin noise images generated at 1x, 2x, 4x, and 8x, respectively.

<img src="resources/images/perlin-1.png" />

<img src="resources/images/perlin-2.png" />

<img src="resources/images/perlin-4.png" />

<img src="resources/images/perlin-8.png" />

These were generated with the following from the REPL:

```cl
  > (loise-img:create-perlin-image "perlin-1.png" 'png 256 128 1)
  ok
  > (loise-img:create-perlin-image "perlin-2.png" 'png 256 128 2)
  ok
  > (loise-img:create-perlin-image "perlin-4.png" 'png 256 128 4)
  ok
  > (loise-img:create-perlin-image "perlin-8.png" 'png 256 128 8)
  ok
```

You can also limit the number of gradations for the shades of grey, giving
the images a more "layered" or "topographical" look:

```cl
> (set grades (loise-util:get-gradations 7))
(0 42.5 85.0 127.5 170.0 212.5 255.0)
> (loise-img:create-perlin-image
    "perlin-7-shades.png" 'png 256 128 8 grades)
ok
```

Which will create the following:

<img src="resources/images/perlin-7-shades.png" />


### Simplex

Below are 4 simplex noise images generated at 1x, 2x, 4x, and 8x, respectively.

<img src="resources/images/simplex-1.png" />

<img src="resources/images/simplex-2.png" />

<img src="resources/images/simplex-4.png" />

<img src="resources/images/simplex-8.png" />

These were generated with the following from the REPL:

```cl
  > (loise-img:create-simplex-image "simplex-1.png" 'png 256 128 1)
  ok
  > (loise-img:create-simplex-image "simplex-2.png" 'png 256 128 2)
  ok
  > (loise-img:create-simplex-image "simplex-4.png" 'png 256 128 4)
  ok
  > (loise-img:create-simplex-image "simplex-8.png" 'png 256 128 8)
  ok
```

Just as with perlin, simplex allows you to limit the number of gradations for
the shades of grey:

```cl
  > (set grades (loise-util:get-gradations 5))
  (0 63.75 127.5 191.25 255.0)
  > (loise-img:create-simplex-image
      "simplex-5-shades.png" 'png 256 128 8 grades)
  ok
```

Which will create the following:

<img src="resources/images/simplex-5-shades.png" />


### ASCII

You can also generate ASCII "images" with loise. As an example of this, we can
map the default values represented by this range:

```cl
  > (loise-util:get-gradations 6)
  (0 51.0 102.0 153.0 204.0 255.0)
```

And by this set of ASCII characters:

* Level 6 - ``A``
* Level 5 - ``^``
* Level 4 - ``n``
* Level 3 - ``*``
* Level 2 - ``~``
* Level 1 - ``~``

By making calls like this:

```cl
> (loise-ascii:create-perlin)
```
<img src="resources/images/perlin-ascii.png" />

And this:

```cl
> (loise-ascii:create-simplex)
```
<img src="resources/images/simplex-ascii.png" />

We can, of course, pass new options to the function. The following shows the
addition of alpine forests and grasslands and greatly increasing the
map area in the terminal:

```cl
> (defun opts ()
    `(#(width 100)
      #(height 42)
      #(multiplier 3.0)
      #(grades ,(loise-util:get-gradations 9))
      #(ascii-map ("A" "^" "!" "n" "*" "-" "~" "~" "~"))
      #(colors (,#'color:whiteb/1 ,#'color:yellow/1 ,#'color:green/1
                ,#'color:green/1 ,#'color:greenb/1 ,#'color:green/1
                ,#'color:blue/1 ,#'color:blue/1 ,#'color:blue/1))
      #(random false)
      #(seed 42)))

> (loise-ascii:create-simplex (opts))
```
<a href="https://raw.githubusercontent.com/lfex/loise/master/resources/images/simplex-ascii-2.png"><img src="resources/images/simplex-ascii-2-small.png" /></a>



## Using Loise

The first place to start is ensuring that the code you obtained works as
expected. To find out, run the unit tests:

```bash
  $ cd loise
  $ make check
```


### From the REPL

Once everything is working, start up an LFE REPL:

```bash
  $ make repl
```

You can now use loise by itself, if you so desire. Here is some example usage:

```cl
  > (loise:perlin 3.14 1.59 2.65)
  -0.3772216257243449
  > (loise:simplex 0.1)
  0.4410072765
  > (loise:simplex 0.1 0.2)
  0.9410934374999996
  > (loise:simplex 0.1 0.2 0.9)
  -0.07602014100000003
```

Or, iterating over some values:

```cl
  > (set input
      (lists:map
        (lambda (x)
          (/ x 10))
        (lists:seq 0 9))))
  (0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9)
  > (lists:map
      (lambda (x)
        (loise:round
          (loise:perlin x)
        2))
      input)
  (0.0 0.11 0.23 0.37 0.46 0.5 0.46 0.37 0.23 0.11)
```


### In a Module

```cl
  (defmodule mymodule
    (export all)
    (import
      (from loise
        (perlin 3)
        (simplex 3))))

  (def get-perlin-pie ()
    (perlin 3.14 1.59 2.65))

  (def get-simplex-pie ()
    (simplex 3.14 1.59 2.65))
```
