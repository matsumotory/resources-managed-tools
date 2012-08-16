## What's managecpu.pl
Perl tool for managed cpu by CFS

## How to use

- 50% cpu rate limit (default)

        ./managecpu.pl sh while.sh

- Cheking "top" command

          PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
         5020 root      20   0  3304  968  840 R 49.9  0.0   0:05.97 sh

- Change $cpu_rate in mangecpu.pl source

    ```perl
     20 # change cpu rate if you want
     21 my $cpu_rate     = 50000;
     22 my $croot        = File::Spec->catfile("/sys", "fs", "cgroup", "cpu");
     23
    ```
