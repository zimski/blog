---
title: "S.O.L.I.D principals, The WHY ?"
layout: post
date: 2018-03-16 20:12
image: /assets/images/post_cover/solid_resized.jpg
headerImage: true
tag:
- code
- programming
- OOP
blog: true
author: zimski
description: A gentel introduction to the WHY of the SOLID principals
---

## Introduction
One of the core truisms of software development is that our beloved project
starts like a beautiful flower with a shiny petals of code. after some
months/years of work, exactly like all biological flowers, the shiny petals will
transform to a messy code and loose everything.

Is this an Universal truth that rule the software engineering or simply the
reflect of his writer's souls ?

Can we do something (in real life) to prevent to crunch this beautiful and
fragile flower and make it stand forever to the face of the sun ?

## How ?
I think that maybe exists somewhere like a recipe of simple rules that can be
followed and make our code more fun and enjoyable to edit,update and extend with
a profitable features.
The recipe of today is the SOLID principle.

## Symptoms
Before digging in the SOLID, it's important to know and identify the pain that
SOLID can help us to prevent.

### The Fragility
What an incredible joy that you feel when you modify a little lines of code somewhere in
your code base and you think that you will have only one or two well identified
tests to fix and when you run your tests .... BOOOMMM everything is broken.

A lot of tests of an unrelated modules with your code update are broken.
You can be thankful to have tests that tell you that otherwise you are a in
shitty position.

The Fragility is the design of a code base that's is easy to break.

So to resume this case, your code is fragile when you do a small update
, you run the tests .... and you finish by crying!

### The Rigidity
This rigidity of your code base make you also cry when you plan an *easy* change
and when you start doing it you starts updating a lots of codes ... a lot.

A small and easy change of on day can take you weeks to be done.

The Rigidity is a design of a code base that's is hard to change

### The Immobility
The immobility is like a very strong glue that stuck your fragile modules in
your code base.
If when day you tell to your self, Oh I have a module that can do
what I want to do, and of course your are a DRY coder, so you will try to take
this module and try to unstuck it to reuse it, but you will break it and break
all your app.

The immobility is the design of a code base that's hard to reuse.

### The Viscosity
The viscosity of software is a strong call that force you to make your thing in
the messy/wrong way, so after you finish your commit you feel so bad about yourself
so you are forced to go cry under a hot shower.

The viscosity is the design that force you to be messy.


## S.O.L.D Principals
This principals are here to help us to prevent the previous things to happen.

1. Single responsibility
2. Open closed principle
3. Liskov substitution principle
4. Interface segregation principle
5. Dependency Inversion Principle

In the next blog posts, I will write about the 5 SOLID principles.

## References
http://staff.cs.utu.fi/~jounsmed/doos_06/slides/slides_060321.pdf
