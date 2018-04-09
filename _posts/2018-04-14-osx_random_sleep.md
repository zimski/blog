---
title: "Random sleeps on Macbook FIXED ..."
layout: post
date: 2018-04-11 20:12
image: /assets/images/post_cover/mac_sleep.jpg
headerImage: true
tag:
- apple
blog: true
author: zimski
description: How to fix the Random sleeps on a Macbook
---

I have a Macbook air since 2014 and doing all my coding on it, so happy with this great machine.

Since 1 year, the computer starts sleeping randomly, sometimes this behavior disappears for months and comeback as mysteriously as it disappears.

# Symptoms
- Your computer goes to sleep randomly (after some seconds or minutes of activity)
- Your computer wake up randomly when it was put in the sleep mode.

All this events occur when the screen is open !

# The root cause
Let's go reading the logs

When the random sleep occur, go to your terminal and type this

```
log show --last 3m > /tmp/log_osx_3
```

This command will save the 3 last minutes logs on a temporally file
You can now do a grep ` cat /tmp/log_osx_3 | grep clamshell` or opening this file in an editor and search for the `clamshell`

In my computer I found:

```shell
2018-04-08 20:20:36.275427+0200 0x993 ... sharingd: [com.apple.sharing:Daemon] Clamshell change detected (clamshell closed: YES, clamshell sleep on close: YES)
...
2018-04-08 20:20:36.331597+0200 0x993 ... sharingd: [com.apple.sharing:Daemon] Clamshell change detected (clamshell closed: NO, clamshell sleep on close: YES)
```

The clamshell is was open and closed in the same second !!, so there is an electronic part in your beloved computer that is malfunctioning.

Even further, the OSx should be able to refuse events like this, it's impossible for a human to open and close a screen in the same second
and should ignore this event.

For now, there is nothing in `Hight Sierra 10.13.4` to solve this issue,

You can mitigate this random sleeping by installing `Insominiax` following this link `http://semaja2.net/ye-ol-projects/insomniaxinfo/`

![disable sleep when lid](/assets/images/post_cover/mac_sleep_1.png)

In this app you can disable sleeping when lid.

Now the logs are :
```
2018-04-08 20:47:58.266642+0200 0x74   ...    kernel: (Insomnia_r11) Insomnia: Message received
2018-04-08 20:47:58.266652+0200 0x74   ...    kernel: (Insomnia_r11) Insomnia: Lid was closed
2018-04-08 20:47:58.266659+0200 0x74   ...    kernel: (Insomnia_r11) Insomnia: kIOPMClamshellOpened sent to root
2018-04-08 20:47:58.266666+0200 0x74   ...    kernel: (Insomnia_r11) ========================
2018-04-08 20:47:58.267002+0200 0x74   ...    kernel: (Insomnia_r11) Insomnia: Message received
2018-04-08 20:47:58.267009+0200 0x74   ...    kernel: (Insomnia_r11) Insomnia: Ignore this message because its artifical!
2018-04-08 20:47:58.267016+0200 0x74   ...    kernel: (Insomnia_r11) ========================
2018-04-08 20:47:58.267587+0200 0x993  ...    sharingd: [com.apple.sharing:Daemon] Clamshell change detected (clamshell closed: YES, clamshell sleep on close: NO)
2018-04-08 20:47:58.267615+0200 0x993  ...    sharingd: [com.apple.sharing:Daemon] Clamshell change detected (clamshell closed: NO, clamshell sleep on close: NO)
2018-04-08 20:47:58.338651+0200 0x74   ...    kernel: (Insomnia_r11) Insomnia: Message received
2018-04-08 20:47:58.338662+0200 0x74   ...    kernel: (Insomnia_r11) Insomnia: Lid was opened
2018-04-08 20:47:58.338669+0200 0x74   ...    kernel: (Insomnia_r11) Insomnia: kIOPMDisableClamshell sent to root
2018-04-08 20:47:58.338676+0200 0x74   ...    kernel: (Insomnia_r11) ========================
2018-04-08 20:47:58.338996+0200 0x74   ...    kernel: (Insomnia_r11) Insomnia: Message received
2018-04-08 20:47:58.339003+0200 0x74   ...    kernel: (Insomnia_r11) Insomnia: Message is for duplicate lid state
2018-04-08 20:47:58.339009+0200 0x74   ...    kernel: (Insomnia_r11) ========================
```

We can see that the app is preventing the sleep when `OSX` is detecting the clamshell changing state.

This will make you computer usable again :) without feeling the need to punch it every time it goes to sleep.


Oh dear OSx developers, can you fix this on the next releases of `OSX` and just make the detection more clever by ignoring state permutation in the same second.

By this action, Your customers can use their Macbook longer and save the planet :)
