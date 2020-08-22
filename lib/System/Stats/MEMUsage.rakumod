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
    # DWORD type is uint32 type
    # $.dwLength is rw for indicate the size of the structure later ($data.dwLength = nativesizeof($data))
    has uint32 $.dwLength is rw; 
    has uint32 $.dwMemoryLoad;
    # DWORDLONG is uint64 type
    has uint64 $.ullTotalPhys;
    has uint64 $.ullAvailPhys;
    has uint64 $.ullTotalPageFile;
    has uint64 $.ullAvailPageFile;
    has uint64 $.ullTotalVirtual;
    has uint64 $.ullAvailVirtual;
    has uint64 $.ullAvailExtendedVirtual;
  };

  use NativeCall;
  
  # https://docs.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-globalmemorystatusex
  sub GlobalMemoryStatusEx(MEMORYSTATUSEX) is native('Kernel32') returns int32 { * };
   
  # Create $data object with MEMORYSTATUSEX class
  my MEMORYSTATUSEX $data .=new;

  # Set $data size to dwLength attribute (is rw)
  $data.dwLength = nativesizeof($data);

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