## What's managecpu.pl
Perl tool for managed cpu by CFS

## How to use
### run-cpu-rate
- 50% cpu rate limit

        ./run-cpu-rate 50 sh while.sh

- Cheking "top" command

          PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
         5020 root      20   0  3304  968  840 R 49.9  0.0   0:05.97 sh

### change-cpu-rate
- Cheking "top" command

          PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
         5023 root      20   0  2304  921  740 R 89.2  0.0   0:02.38 sh

- Change cpu rate

        ./change-cpu-rate -p 5023 -r 30

- Cheking "top" command

          PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
         5023 root      20   0  2304  921  740 R 29.9  0.0   0:03.18 sh

- Unset cpu rate

        ./change-cpu-rate -p 5023 -r 0
