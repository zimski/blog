---
title: "JavaScript generators"
layout: post
date: 2017-01-01 22:48
image: /assets/images/markdown.jpg
headerImage: false
tag:
- javascript
- generator
- extra
blog: true
author: zimski
description: Diving in the javascript generator super powers
# jemoji: '<img class="emoji" title=":ramen:" alt=":ramen:" src="https://assets.github.com/images/icons/emoji/unicode/1f35c.png" height="20" width="20" align="absmiddle">'
---

<div id="table-of-contents">
<h2>Table of Contents</h2>
<div id="text-table-of-contents">
<ul>
<li><a href="#org8e9e8a0">1. JS functions behavior</a></li>
<li><a href="#org86560e0">2. Generators</a>
<ul>
<li><a href="#orgdf848a3">2.1. Syntax</a></li>
<li><a href="#org7706a85">2.2. Iterator</a></li>
<li><a href="#org8d2d374">2.3. Call next with params</a></li>
<li><a href="#org3bcfef6">2.4. Sync generator</a>
<ul>
<li><a href="#orgef4040f">2.4.1. Add a sync wrapper</a></li>
<li><a href="#orgd89e878">2.4.2. Handle error in a nice try catch</a></li>
<li><a href="#org5d178b7">2.4.3. Async Flow control</a></li>
<li><a href="#org93282ae">2.4.4. Promises instead of callbacks</a></li>
</ul>
</li>
</ul>
</li>
<li><a href="#orge7cf639">3. Compose Generator</a>
<ul>
<li><a href="#orgc8b49e0">3.1. yield* delegating generators</a></li>
<li><a href="#orge5898b4">3.2. f o f'</a></li>
</ul>
</li>
</ul>
</div>
</div>


<a id="org8e9e8a0"></a>

# JS functions behavior

Main note: any new function can't interrupt a ruining function

    setTimeout(function(){
      console.log("Hello World");
    },1);

    function foo() {
      // NOTE: don't ever do crazy long-running loops like this
      for (var i=0; i<=1E10; i++) {
          console.log(i);
      }
    }

    foo();
    // 0..1E10
    // "Hello World"

In this example, the console.log function can't interrupt the foo function.
So it's need to waits the end of foo to run


<a id="org86560e0"></a>

# Generators

new feature implemented in ES6
Make possible to interrupt function and restart.
Make possible two-way communications


<a id="orgdf848a3"></a>

## Syntax

    function *coucou() {
      yield 1;
      yield 2;
      yield 3;
      yield 4;
      return 5;
    }
    // call the generator
    var coucouIterator = coucou()
    coucouIterator.next()
    => { value: 1, done: false }
    ....
    // the last element will be with done: true
    // the done true is from the value returned by `return` call
    => { value: 5, done: true }


<a id="org7706a85"></a>

## Iterator

You can iterate over the generator by calling the \`next()\` method
You can also use the \` for .. of .. \`

    for ( let val of coucou() ) console.log(val);
    // => 1 2 3 4
    // we can't get to 6 !!

Notice: with the \`for\` iteration, the last element returned by \`return\` is ignored


<a id="org8d2d374"></a>

## Call next with params

The param sent by the \`next\` will be returned by \`yield\` inside the function

    function *hello() {
      var valueSentByNext = ( yield 'value sent' )
      return valueSentByNext;
    }
    var helloI = hello();
    hello.next('booo');
    => { value: 'value sent', done: false }
    hello.next();
    => { value: 'booo', done: true }

You can imagine this params like sending commands to your generator like resting
the internal counter or changing the behavior.


<a id="org3bcfef6"></a>

## Sync generator

[Great video about generators, sync & flow control](https://www.youtube.com/watch?v=s-BwEk-Y4kg)
I tried here to implement what [Co library](https://github.com/tj/co) do for you, the purpose of this
is to explain how really all of this magic works under the hood.
This also helps you to explain the code behind this library.
I always encourage you to read and understand how the libraries that you use
in your projects works.


<a id="orgef4040f"></a>

### Add a sync wrapper

    function sync(gen) {
     var iterable
     function resume(err, data) {
       iterable.next(data)
     }
     iterable = gen(resume);
     iterable.next();
    }

    sync(function* (resume) {
      var userData = yield $http.fetch('/users/1', resume)
      var posts = yield $http.post('/posts/user/' + userData.id, resume)
      ....
    }


<a id="orgd89e878"></a>

### Handle error in a nice try catch

Error in async operations like callbacks are not catched by a \`try&#x2026;catch\`
We can add easily an error handling in our \`sync\` function like this

    function sync(gen) {
     var iterable
     function resume(err, data) {
       if (err) iterable.throw(err) // we raise a error catchable by the try..catch
       iterable.next(data)
     }
     iterable = gen(resume);
     iterable.next();
    }

    sync(function* (resume) {
      try {
      var userData = yield $http.fetch('/users/1', resume)
      var posts = yield $http.post('/posts/user/' + userData.id, resume)
      ....
      } catch(err) { /* error manage */ }
    }


<a id="org5d178b7"></a>

### Async Flow control

    ...
    var nbValuesNeeded = 0;
    var retrivedData = [];

    function resume(){
      valueNeeded +=1;
      return function(err, data) {
        retrivedData[nbValuesNeeded] = data;
        nbValueNeeded -=1
        if (valueNeeded === 0){
          iterable.next(retrivedData);
          nbValuesNeeded = 0
          retrivedData = [];
      }
    }
    ...


<a id="org93282ae"></a>

### Promises instead of callbacks

In our code, we do the assumption that all cb are defined like this (err, data)
It's not the case always.
Dealing with promises is more robust because it's well specified and behave always
in a same manner, we have a \`resolve\` containing data and a \`reject\` containing error.


<a id="orge7cf639"></a>

# Compose Generator


<a id="orgc8b49e0"></a>

## yield\* delegating generators


<a id="orge5898b4"></a>

## f o f'

We can compose several generators and get interesting behavior.
We can imagine have a wrapper that run code before and after some code.
For this example, I have a list of middleware that do what an middleware
is supposed to do in a HTTP world

    const ctx = {
      body: '',
      headers: {}
    };
    function* middleware1(next){
      console.log("compute the request duration"
      const beforeT = date();
      yield* next
      const afterT = date();
      console.log("total duration");
      console.log(( beforeT - afterT ) + ' ms');
    }

    function* middleware2(next){
      console.log(">> logging before"
      yield* next
      console.log(">> logging after"
    }
    function* middleware3(){
      console.log(">> heavy computation"
      // sett the body
      this.body = 'coucou';
    }

Now, we will compose our middlewares and binding the ctx as a \`this\`.

    const moulinette = middleware1.call(ctx,
                         middleware2.call(ctx,
                           middleware3.call(ctx)));
    // execute the moulinette
    moulinette.next()
    > compute the request duration
    >> logging before
    >>> do heavy computation
    >> logging after
    > total duration
    > 45 ms
    // ctx is ready now
    // send it to the client

You have to note that this code is for educational purpose only.
The main goal here is to compose generators and do some magic.

[KoaJS](http://koajs.com/) is using the same mechanism internally but more beautifully written ;)
