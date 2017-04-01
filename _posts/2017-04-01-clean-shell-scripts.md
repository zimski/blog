---
title: "Write clean bash scripts ;)"
layout: post
date: 2017-03-31 22:48
image: /assets/images/post_cover/bash_clean_resized.jpg
headerImage: true
tag:
- shell
- bash
- test
blog: true
author: zimski
description: Let's try to write a clean bash scripts
---

## Why write clean shell scripts
Writing shell scripts can become very messy, the reason behind it, for me is
that we consider the shell scripts as an utility and not as a real language ( if
you think this, you are wrong, bash is magic and very powerful as a
programming language).

-------------------------------

Function first
=================

My first advice is to embed every thing in an function, even the main

We should have simple components/functions, and chaining theme together we will can
handle complex problem.

In your code, your function should be simple, few lines and should do one thing.
Your function should follow the rules applied in the functional programming so
they should be [PURE](https://en.wikipedia.org/wiki/Pure_function) !

``` bash
function command1 {
 # code body
}

function command2 {
 # code body
}

function main {
  command1
}

#run the code
main
```
### Function params
To access to params inside function, we use the `$INDEX`, the `INDEX` is related to
the position of the param.

``` bash
say_function hello bob
              $1    $2
```

To make this cleaner inside function definition and not add confusion when we
handle more than one params, you should associate the params to a local variable
to make things easier to follow.

``` bash
function say_function {
  verbe=$1
  name=$2

  echo "$verbe $name :)"
}
```
In the next blog post, I will show you how to test this beautiful functions.

### Use stdout
What I have allways liked and admired in the shell is this ability to compose commands
that communicate with each other using stdin and stdout. simple, clean and
beautiful.

So, it make every thing clear when you call function, if the function is
supposed to return something, so you will know immediately where to pick the
result.

So your function receive data from **params** and put the result to **stdout**
instead of the params, your function can read from the **stdin** but I will not
discuss about this in this blog post.


### Flow re-directions

Imagine you have the case when you need to call `function2` with the result of
`function1`.
The things here, is the result of `function1` can be a text or a long string
with a lot of spaces.

Let's first see how it can be problematic.

``` bash
function list_friends {
 echo 'kamal peter yassin chakib'
}

function say_bye {
  echo "Oh my friends: $1, bye bye !"
}

say_bye $(list_friends)

// the resutl
Oh my friends: kamal, bye bye !
```

As you can see, say_bye has considred only the first name, after the evaluation
of `$(list_friends)` we have `say_bye kamal peter yassin chakib` and the first
params is `$1 == kamal`.

To solve this issue we can use the magic of redirection provided by bash.
Let"s try to play with it:
```bash
say_bye <(list_friends)
# => Oh my friends: /dev/fd/45, bye bye
```

So the `<` allocate for us a file descriptor and inject the output of
`list_friends` in it.
To read the content of a file descriptor we will use a simple `cat`

``` bash
function say_bye {
  echo "Oh my friends: $(cat $1), bye bye !"
}
```
This is very useful when you need to manipulate an output of a function as a
file, and calling on it a commands that are waiting to have files as input.

``` bash
function get_old_file {
   # will echo/cat the content of the file
}

function get_new_file {
   # will echo/cat the content of the file
}

function compute_diff {
  diff <(get_old_file) \
       <(get_new_file)
}
```

-----------------------------

Variables
===========

### Do not use global variables
You should use global variables only for constants like API keys, log path  ...
ect. otherwise it's forbidden :)

### Use the same formatting for variables name
Personally, for constants, I use the upper case like `API_KEY`
Local variables ( inside functions ), I use the lower case `parameter_name`

--------------------------

General shape
================

### One line, One responsibility
Try in your code to have each line responsible for doing one thing, thanks to `\` that permit us to
breaks one line into multiple lines.

``` bash
 curls -XGET http://www.google.fr \ # this line will fetch the page
 | wc -c                            # this line will compute the number of chars
```

This also will make your code easy to follow and update.

----------------------------

Conclusion
============
So I have shown you some tricks to make you bash more cleaner, obviously it's
not the only way but this rules can help you to start make things cleaner.

I the next blog post I will show you how to tests this shell scripts and be
confident about their behaviour and at the end have shell scripts production
ready !

Have a good day.
