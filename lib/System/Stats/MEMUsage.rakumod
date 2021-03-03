use v6;

unit module System::Stats::MEMUsage;

sub MEM_Usage ( ) is export {

  my $ret;  
  
  given $*KERNEL {
    when /linux/  { $ret = linux() }
    when /win32/  { $ret = win32() }    
  }

  return $ret;

}

sub linux ( ) {

  # KB to Bytes
  my $scale = 1024; 

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
    'usage-percent' => $mem-usage-percent
  };

}

sub win32 ( ) {

  # https://docs.microsoft.com/en-us/windows/win32/api/sysinfoapi/ns-sysinfoapi-memorystatusex
  class MEMORYSTATUSEX is repr("CStruct") {
    my constant DWORD = uint32;
    my constant DWORDLONG = uint64;
    # $.dwLength is size of the structure
    has DWORD $.dwLength = nativesizeof(::?CLASS); 
    has DWORD $.dwMemoryLoad;
    has DWORDLONG $.ullTotalPhys;
    has DWORDLONG $.ullAvailPhys;
    has DWORDLONG $.ullTotalPageFile;
    has DWORDLONG $.ullAvailPageFile;
    has DWORDLONG $.ullTotalVirtual;
    has DWORDLONG $.ullAvailVirtual;
    has DWORDLONG $.ullAvailExtendedVirtual;
  };

  use NativeCall;
  
  # https://docs.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-globalmemorystatusex
  sub GlobalMemoryStatusEx(MEMORYSTATUSEX) is native('Kernel32') returns int32 { * };
   
  # Create $data object with MEMORYSTATUSEX class
  my MEMORYSTATUSEX $data .=new;

  # Get the data
  GlobalMemoryStatusEx($data);

  # Return the data
  return {
    'total' => $data.ullTotalPhys,
    'free'  => $data.ullAvailPhys,
    'used'  => ($data.ullTotalPhys - $data.ullAvailPhys),
    'usage-percent' => $data.dwMemoryLoad
  };  
}
