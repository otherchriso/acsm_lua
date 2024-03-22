# Various Lua scripts for Assetto Corsa Server Manager

This repo contains scripts which might be in use, under development, or not, or anything really.

They're intended for use with ACSM which you can find via https://wiki.emperorservers.com/assetto-corsa-server-manager. 

Please note, there is an open source version at https://github.com/JustaPenguin/assetto-server-manager but this code has only really been used and maybe tested with ACSM v2.x.

## Features
* Define a fixed-setup that will be automatically applied to the cars chosen by a registrants
* Define a fixed ballast that will be applied to all cars of a given type (added to any manually-applied ballast the championship admin might have also set on a person's entry slot)
* Define a fixed restrictor that will be applied to all cars of a particular type  (added to any manually-applied restrictor the championship admin might have also set on a person's entry slot)
* Override all ballast OR restrictor for registered entrants based on their position in the championship standings
* Override all ballast OR restrictor for registered entrants based on their finishing order in the most recent championship race ("race 1" for events which had a second race in the session, e.g. ignoring result of reverse grid)
* Override all ballast OR restrictor for registered entrants based on their finishing order in the most recent championship race ("race 2" for events which had a second race in the session, e.g. using the result of a reverse grid race)

## Known issues

* Race Weekends not supported

## Support
No support is offered for these scripts.

The best support for anything ACSM-related is the [Emperor Servers Discord](https://discordapp.com/invite/6DGKJzB).

It is highly recommended to test everything first in an ACSM installation that isn't your production server people rely on. The 'current config' page under ACSM's server menu is a good place to see the scripts operating withoug having to join the game.

## Warranty
No warranty is provided, or implied.

## License
Yes the license file here is real. Some content has been adapted from https://github.com/JustaPenguin/assetto-server-manager which has its own license.
