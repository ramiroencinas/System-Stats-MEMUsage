my %mem = MEM_Stats();

say "Total : %mem<total> bytes";
say " Free : %mem<free> bytes";
say " Used : %mem<used> bytes";
say "Usage : %mem<usage>%";

sub MEM_Stats ( ) is export {

  my %ret;  
  
  given $*KERNEL {
    when /linux/  { %ret = linux() }
    when /win32/  { %ret = win32() }    
  }

  return %ret;

}

sub linux ( ) {

  my $scale = 1024; # from KB to Bytes

  my $mem-usage-percent;
  my $mem-total;
  my $mem-free;
  my $mem-used;

  my $sourcefile = '/proc/meminfo';

  for $sourcefile.IO.open.lines {

    if $_ ~~ /MemTotal\:\s+$<total>=[\d+]/ {$mem-total = $<total>.Int * $scale;}
    if $_ ~~ /MemFree\:\s+$<free>=[\d+]/   {$mem-free = $<free>.Int * $scale;}

  }

  $mem-used = $mem-total - $mem-free;

  $mem-usage-percent = (($mem-used * 100) / $mem-total).Int;

  return {
        'total' => $mem-total,
        'free'  => $mem-free,
        'used'  => $mem-used,
        'usage' => $mem-usage-percent
  };

}

sub win32 ( ) {

  my $scale = 1048576; # from MB to Bytes

  my $mem-usage-percent;
  my $mem-total;
  my $mem-free;
  my $mem-used;

  my @systeminfo = ((shell "systeminfo /FO CSV /NH", :out, :enc<utf8-c8> ).out.slurp-rest).split(',').grep(/\sMB/); 

  # MemTotal
  if @systeminfo[0] ~~ /^\"$<total>=[.*?]\sMB\"/ {$mem-total = $<total>.Int * $scale;}

  # MemFree
  if @systeminfo[1] ~~ /^\"$<free>=[.*?]\sMB\"/ {$mem-free = $<free>.Int * $scale;}

  $mem-used = $mem-total - $mem-free;

  $mem-usage-percent = (($mem-used * 100) / $mem-total).Int;

  return {
  	'total' => $mem-total,
  	'free'  => $mem-free,
  	'used'  => $mem-used,
  	'usage' => $mem-usage-percent
  };  

}


