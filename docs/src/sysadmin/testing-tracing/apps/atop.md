## atop example

```
 $ atop -f -m -A -1 1
  PRC | sys    0.79s |               | user   4.57s |              |              |  #proc   2136 | #trun      6 |              |  #tslpi  4431 | #tslpu   542 |              | #zombie    2  | clones  18/s |              |              |  no  procacct |              |
  CPU | sys      83% |               | user    459% | irq       9% |              |               |              | idle   9139% |  wait      1% |              | steal     0% |               | guest     0% |              |              |  curf 1.41GHz |              |
  CPL | avg1    7.28 |               | avg5    7.82 |              | avg15   7.72 |               |              |              |  csw  50710/s |              |              | intr 37527/s  |              |              |              |  numcpu    96 |              |
  MEM | tot   251.4G | free   19.3G  | cache  74.8G | dirty  28.7M |              |  buff   17.9M | slab  118.0G | slrec 109.6G |               | shmem 409.8M | shrss   0.0M | shswp   0.0M  |              |              |              |               | numnode    2 |
  SWP | tot   242.1G |               | free  153.8G |              | swcac   1.6G |               |              |              |               |              |              |               |              | vmcom 486.9G |              |  vmlim 367.8G |              |
  PAG | scan     0/s | steal    0/s  |              | stall    0/s | compact  0/s |               | numamig  0/s | migrate  0/s |               |              |              |               |              | swin     0/s | swout    0/s |               | oomkill  0/s |
  DSK |    nvme0c0n1 | busy      0%  |              | read     0/s | write    0/s |               | discrd   0/s | KiB/r      0 |               | KiB/w      0 | KiB/d      0 | MBr/s    0.0  |              | MBw/s    0.0 | avq     0.00 |               | avio  0.0 ns |
  DSK |      nvme0n1 | busy      0%  |              | read     0/s | write    0/s |               | discrd   0/s | KiB/r      0 |               | KiB/w      0 | KiB/d      0 | MBr/s    0.0  |              | MBw/s    0.0 | avq     0.00 |               | avio  0.0 ns |
  DSK |          sda | busy      0%  |              | read     0/s | write    0/s |               | discrd   0/s | KiB/r      0 |               | KiB/w      0 | KiB/d      0 | MBr/s    0.0  |              | MBw/s    0.0 | avq     0.00 |               | avio  0.0 ns |
  NFM | /hpc4project | srv sc-hpc4-  | read   23K/s | write  39K/s |              |               | nread  19K/s | nwrit 3.0M/s |               | dread 0.0K/s | dwrit 0.0K/s |               | mread  24K/s |              | mwrit  40K/s |               |              |
  NFM |    /hpc4home | srv sc-hpc4-  | read   23K/s | write  39K/s |              |               | nread  19K/s | nwrit 3.0M/s |               | dread 0.0K/s | dwrit 0.0K/s |               | mread  24K/s |              | mwrit  40K/s |               |              |
  NFC | rpc   5905/s |               | read     2/s | write    1/s |              |  retxmit  0/s |              | autref 6e3/s |               |              |              |               |              |              |              |               |              |
  NFS | rpc      0/s | cread    0/s  | cwrit    0/s |              | MBcr/s   0.0 |  MBcw/s   0.0 |              | nettcp   0/s |  netudp   0/s |              | rchits   0/s | rcmiss   0/s  | rcnoca   0/s |              | badfmt   0/s |  badaut   0/s | badcln   0/s |
  NET | transport    | tcpi  7609/s  |              | tcpo  7108/s | udpi     0/s |               | udpo     0/s | tcpao    1/s |               | tcppo    1/s | tcprs    0/s | tcpie    0/s  |              | tcpor    0/s | udpnp    0/s |               | udpie    0/s |
  NET | network      |               | ipi   7609/s | ipo   7101/s |              |  ipfrw    0/s |              | deliv 7609/s |               |              |              |               |              |              | icmpi    0/s |  icmpo    0/s |              |
  NET | eno1239   0% |               | pcki  2774/s | pcko  1234/s |              |               | sp   10 Gbps | si   26 Mbps |  so  757 Kbps |              | coll     0/s | mlti     0/s  | erri     0/s |              | erro     0/s |  drpi     0/s | drpo     0/s |
  NET | enp161s   0% |               | pcki  5912/s | pcko  5931/s |              |               | sp  100 Gbps | si 8809 Kbps |  so 9324 Kbps |              | coll     0/s | mlti     0/s  | erri     0/s |              | erro     0/s |  drpi     0/s | drpo     0/s |
  IFB | lx5_0/1   0% |               | pcki     0/s | pcko     0/s |              |               | sp  100 Gbps | si    0 Kbps |  so    0 Kbps | lanes      4 |              |               |              |              |              |               |              |

      PID           TID        MINFLT        MAJFLT       VSTEXT        VSLIBS         VDATA       VSTACK        LOCKSZ         VSIZE        RSIZE         PSIZE         VGROW        RGROW        SWAPSZ        RUID           EUID             ACPU        CMD       1/80
  2250991             -           0/s           0/s         2.3M         76.5M         14.8G       152.0K          0.0K         15.0G         2.7G            0B            0B           0B            0B        hemraj         hemraj           101%        python3
  2253815             -           0/s           0/s         2.3M         76.5M         14.8G       152.0K          0.0K         15.0G         2.7G            0B            0B           0B            0B        hemraj         hemraj           101%        python3
  2248736             -           0/s           0/s         2.3M         76.5M         14.8G       152.0K          0.0K         15.0G         2.7G            0B            0B           0B            0B        hemraj         hemraj           101%        python3
  2249150             -           0/s           0/s         2.3M         76.5M         14.8G       152.0K          0.0K         15.0G         2.7G            0B            0B           0B            0B        hemraj         hemraj           100%        python3
  3815483             -           0/s           0/s         2.0M          1.9G          5.1G       156.0K          0.0K          8.1G        33.2M            0B            0B           0B        522.0M        xzhaobx        xzhaobx          100%        python 
  2278628             -           0/s           0/s       172.0K          2.4M         19.9M       136.0K         33.1M         33.1M        30.6M            0B            0B           0B            0B        kftse          kftse             12%        atop
  2060558             -          96/s           0/s        37.8M          4.2M          5.0G       136.0K          0.0K          5.9G         4.9G            0B            0B       768.0K            0B        hzhanggp       hzhanggp           6%        node
  2279151             -           0/s           0/s         4.0K          7.8M          6.6M       132.0K          0.0K         19.6M        15.0M            0B            0B           0B            0B        shanau         shanau             6%        python3
  1929618             -           5/s           0/s         8.0K        119.4M        990.5M       152.0K          0.0K          1.2G       275.4M            0B            0B           0B         46.5M        mdatp          mdatp              2%        wdavdaemon
    47064             -           0/s           0/s         8.0K        106.4M          1.9G       132.0K          0.0K          2.1G        65.3M            0B            0B           0B         21.2M        root           root               2%        wdavdaemon
  3847840             -           0/s           0/s        48.0K          5.5M        576.0K       136.0K          0.0K         18.0M         5.2M            0B            0B           0B            0B        tingxu         tingxu             2%        sftp-server
  2060598             -           0/s           0/s        37.8M          7.9M        654.2M       136.0K          0.0K         82.8G       583.7M            0B            0B           0B            0B        hzhanggp       hzhanggp           1%        node
  2060531             -           0/s           0/s        37.8M          4.2M         99.0M       136.0K          0.0K          1.1G        83.1M            0B            0B           0B            0B        hzhanggp       hzhanggp           1%        node
    47010             -           0/s           0/s         8.0K        107.6M          2.9G       260.0K          0.0K          3.1G        78.5M            0B            0B           0B        120.8M        root           root               1%        wdavdaemon
    1580             -           0/s           0/s       144.0K         11.5M         11.7M       132.0K          0.0K         82.7M        37.7M            0B            0B           0B            0B        root           root               1%        sssd_nss
  2978774             -           0/s           0/s         2.0M        133.0M        189.5M       140.0K          0.0K          1.1G        27.1M            0B            0B           0B        123.8M        xzhaobx        xzhaobx            1%        python
  3773492             -           0/s           0/s       572.0K         11.6M          3.4M       132.0K          0.0K         49.3M         8.3M            0B            0B           0B            0B        tingxu         tingxu             1%        sshd
  2228034             -           0/s           0/s           0B            0B            0B           0B          0.0K            0B           0B            0B            0B           0B            0B        root           root               1%        kworker/u389:4
  2236402             -           0/s           0/s           0B            0B            0B           0B          0.0K            0B           0B            0B            0B           0B            0B        root           root               1%        kworker/u389:6
  3678992             -           0/s           0/s        37.8M          4.2M          6.0G       136.0K          0.0K          7.2G         5.9G            0B            0B           0B         51.8M        hzhanggp       hzhanggp           0%        node
  2061015             -         167/s           0/s        79.8M         15.5M          2.4G       136.0K          0.0K         74.9G         2.1G            0B            0B           0B        180.5M        kezdyang       kezdyang           0%        node
  2059376             -           3/s           0/s        79.8M          5.2M          4.2G       136.0K          0.0K         15.3G         1.3G            0B            0B           0B          2.9G        kezdyang       kezdyang           0%        node
  2074388             -           0/s           0/s        37.8M         11.2M        844.9M       136.0K          0.0K         13.8G       789.4M            0B            0B           0B            0B        hzhanggp       hzhanggp           0%        node
  1508752             -           0/s           0/s         2.0M        655.0M          4.6G       180.0K          0.0K          7.5G       680.4M            0B            0B           0B            0B        kezdyang       kezdyang           0%        tensorboard   
```

## atop service settings

```
$ cat /usr/share/atop/atop.daily
#!/usr/bin/sh

LOGOPTS=""        # default options
LOGINTERVAL=600       # default interval in seconds
LOGGENERATIONS=28     # default number of days
LOGPATH=/var/log/atop                   # default log location

# allow administrator to overrule the variables
# defined above
#
DEFAULTSFILE=/etc/sysconfig/atop    # possibility to overrule vars

if [ -e "$DEFAULTSFILE" ]
then
  . "$DEFAULTSFILE"

  # validate overruled variables
  # (LOGOPTS and LOGINTERVAL are implicitly by atop)
  #
  case "$LOGGENERATIONS" in
      ''|*[!0-9]*)
    echo non-numerical value for LOGGENERATIONS >&2
    exit 1;;
  esac
fi

CURDAY=`date +%Y%m%d`
BINPATH=/usr/bin
PIDFILE=/var/run/atop.pid

# verify if atop still runs for daily logging
#
if [ -e "$PIDFILE" ] && ps -p `cat "$PIDFILE"` | grep 'atop$' > /dev/null
then
  kill -USR2 `cat "$PIDFILE"`       # final sample and terminate

  CNT=0

  while ps -p `cat "$PIDFILE"` > /dev/null
  do
    CNT=$((CNT + 1))

    if [ $CNT -gt 5 ]
    then
      break;
    fi

    sleep 1
  done

  rm "$PIDFILE"
fi

# delete logfiles older than N days (configurable)
# start a child shell that activates another child shell in
# the background to avoid a zombie
#
( (sleep 3; find "$LOGPATH" -name 'atop_*' -mtime +"$LOGGENERATIONS" -exec rm {} \;)& )

# activate atop with an interval of S seconds (configurable),
# replacing the current shell
#
echo $$ > $PIDFILE
exec $BINPATH/atop $LOGOPTS -w "$LOGPATH"/atop_"$CURDAY" "$LOGINTERVAL" > "$LOGPATH/daily.log" 2>&1
```

## atop help

```
$ atop --help
atop: invalid option -- '-'
Usage: atop [-flags] [interval [samples]]
    or
Usage: atop -w  file  [-S] [-a] [interval [samples]]
       atop -r [file] [-b [YYYYMMDD]hhmm] [-e [YYYYMMDD]hhmm] [-flags]

  generic flags:
    -V  show version information
    -a  show or log all processes (i.s.o. active processes only)
    -R  calculate proportional set size (PSS) per process
    -W  determine WCHAN (string) per thread
    -P  generate parseable output for specified label(s)
    -Z  no spaces in parseable output for command (line)
    -L  alternate line length (default 80) in case of non-screen output
    -f  show fixed number of lines with system statistics
    -F  suppress sorting of system resources
    -G  suppress exited processes in output
    -l  show limited number of lines for certain resources
    -y  show threads within process
    -Y  sort threads (when combined with 'y')
    -1  show average-per-second i.s.o. total values

    -x  no colors in case of high occupation
    -g  show general process-info (default)
    -m  show memory-related process-info
    -d  show disk-related process-info
    -n  show network-related process-info
    -s  show scheduling-related process-info
    -v  show various process-info (ppid, user/group, date/time)
    -c  show command line per process
    -o  show own defined process-info
    -u  show cumulated process-info per user
    -p  show cumulated process-info per program (i.e. same name)
    -j  show cumulated process-info per container

    -C  sort processes in order of cpu consumption (default)
    -M  sort processes in order of memory consumption
    -D  sort processes in order of disk activity
    -N  sort processes in order of network activity
    -E  sort processes in order of GPU activity
    -A  sort processes in order of most active resource (auto mode)

  specific flags for raw logfiles:
    -w  write raw data to   file (compressed)
    -r  read  raw data from file (compressed)
        symbolic file: y[y...] for yesterday (repeated)
        file name '-': read raw data from stdin
    -S  finish atop automatically before midnight (i.s.o. #samples)
    -b  begin showing data from specified date/time
    -e  finish showing data after specified date/time

  interval: number of seconds   (minimum 0)
  samples:  number of intervals (minimum 1)

If the interval-value is zero, a new sample can be
forced manually by sending signal USR1 (kill -USR1 pid_atop)
or with the keystroke 't' in interactive mode.

Please refer to the man-page of 'atop' for more details
```
