# System::Stats::MEMUsage
[![Build Status](https://travis-ci.com/ramiroencinas/System-Stats-MEMUsage.svg?branch=master)](https://travis-ci.com/github/ramiroencinas/System-Stats-MEMUsage)

Raku module - Provides Memory Usage statistics.

## OS Supported: ##
* GNU/Linux by /proc/meminfo
* Win32 by Kernel32/GlobalMemoryStatusEx function Native call

## Installing the module ##

    zef update
    zef install System::Stats::MEMUsage

## Example Usage: ##

```raku 
use v6;
use System::Stats::MEMUsage;    

my %mem = MEM_Usage();

say "Total: %mem<total> bytes";
say " Free: %mem<free> bytes";
say " Used: %mem<used> bytes";
say "Usage: %mem<usage-percent>%";
```