use v6;
use lib 'lib';
use Test;

plan 2;

use System::Stats::MEMUsage;
ok 1, "use System::Stats::MEMUsage worked!";
use-ok 'System::Stats::MEMUsage';