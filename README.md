This is a [Factorio](http://www.factorio.com/) mod. It adds a small UI frame
that informs you of the current state of any circuit signals attached to a
"Production Monitor" entity.


## How do I use this? ##

The Production Monitor (prodmon) system consists of two parts:

1. The titular production monitor, a combinator that can be hooked up by
circuit wire to any network, and which can then see all the signals on the
wire, and

2. A HUD element showing every monitor's signals, with particular details:
    - the signal's current value,
    - percentage of fullness (learned from the signal's history),
    - rate of change, and
    - estimated time to full/empty (based on the rate of change).

At present, there are no filters, so only show the monitor the signals you care
about (use some other combinator to black- or whitelist as desired).


## Many thanks for ##

* The [encouragement of the Reddit Factorio community](https://www.reddit.com/r/factorio/comments/6apj6l/who_uses_yarm_anymore/).


## License ##

The source of **Prodmon** is Copyright 2017 Octav "narc" Sandulescu. It
is licensed under the [MIT license][mit], available in this package in the file
[LICENSE.md](LICENSE.md).

[mit]: http://opensource.org/licenses/mit-license.html


## Statistics ##

89 Production Monitors were placed, mined, placed again, and generally abused
during the creation of this mod.
