---
title: "Anonymous Functions in JavaScript"
layout: post
date: 2017-02-07 22:48
image: /assets/images/post_cover/resized_anony.jpg
headerImage: true
tag:
- javascript
- function
- anonymous
- extra
blog: true
author: zimski
description: Anonymous functions, the bad side
---
# Anonymous Functions, bad or not ?

Hello every one, This small blog post is about anonymous function.
The anonymous function is basically a function without a name, when reading
JavaScript codes, you often see them

```javascript
function hi(){
  console.log('Hi, I have a name :)');
}

var anonymousFunction = function(){
  console.log('Hi, I don\'t have a name :(');
};

anounymousHi();
// => Hi, I don't have a name :(

hi();
// => Hi, I have a name :)
```

Okay, every thing is good until now, we can use `anounymousHi` as a normal
declared one `hi`;

Things starts to go nasty when this bodies start to throw errors

So, to experiment this, go to [https://jsfiddle.net/fuaxa1yw/][JsFiddle]
I have prepared for you a little example.

the code inside

```javascript
function namedFunction(){
  throw new Error('You know my name')
};
setTimeout(function() {throw new Error('just guess it ;)')},1);

setTimeout(namedFunction,1);
```

You can run the code inside the Jsfiddle and open your browser console (right
click + inspect then open the console tab)

You can see this cute red errors
![console errr](/assets/images/anony_pic1.png)

So, when errors are thrown, in the debug console, we can find the function name
for the second error `namedFunction` but not for the anonymous one !

Imagine your self in a large code base, and get this error with no function
name, so you will have trouble to find where the error is occurred.

So, my advice for you, set name for your function even where it's not sexy ;)

[JsFiddle]: https://jsfiddle.net/fuaxa1yw/
