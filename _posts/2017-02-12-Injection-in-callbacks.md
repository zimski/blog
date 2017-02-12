---
title: "[ Injection part 1 ] Injection in callbacks"
layout: post
date: 2017-02-12 21:46
image: /assets/images/post_cover/injections1_resized.jpg
headerImage: true
tag:
- javascript
- function
- injection
blog: true
author: zimski
description: A cool pattern about Injection
---

# Injection in callbacks

Holaa !, I want to discuss with you about a cool form of injection.
I don't know the right name for this so I will call it `Injection in callbacks`.

I am sure if you have done some unit test before ( and you should ;) ) specially
with async code.

In `mocha` library test based

```javascript
it('should do the right thing', function(done) {
  asyncTask(function(data) {
    data.should.be.good;
    done();  // mmmmm who is this ?!
  });
});
```

the done here will tell the test if the async call succeed or not, specially
used when you want to send an error !

Okay so done is a function injected as a param `function(done)...` to the test
function ( the callback of `it`)

I found this pattern really cool, the main function will make a function with
the right params inside (closure benefit) and send it to it callback.
The callback will have the control on when running it.
One part make the closure, the other part will run it.

## Let's code it in a useful example:

I want to code a function responsible of computing the execution duration of an
asyc function.

This function will send the duration to a Bstats server.

Let's code it:

```javascript
function duration(cb, metricName){
  var dateStart = Date.now();

  function done() {
    const time = Date.now() - dateStart;
    Bstats.timing(metricName, time);
    return time;
  }
  cb(done) // the magic is here, we call our cb with our done function
}
```

So this example is very easy to understand, we make the `done` function with the
metric name and when fired, it will send the computed duration time.
The done function even return the computed duration, maybe it can be used for
additional logging.

To use it:

```javascript
duration(function(done){
  saveOnDB(data, function(err){
   console.log('the data saving lasted ' + done() + ' ms');
  });
}, 'storage.save.time')
// => the data saving lasted 13 ms
// the metric of timing is sent too with the right time
```

That's it !
