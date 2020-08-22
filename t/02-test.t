use v6;
use lib 'lib';
use Test;

plan 4;

use System::Stats::MEMUsage;

my %mem = MEM_Usage();

ok ( %mem<total> > 0 ), "Total Memory > 0";
ok ( %mem<free> >= 0 ), "Free Memory >= 0";
ok ( %mem<used> > 0 ),  "Used Memory > 0";
ok ( %mem<usage-percent> >= 0 && %mem<usage-percent> <= 100 ), "MEMUsage% >= 0 and <= 100";