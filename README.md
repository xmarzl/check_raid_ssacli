# check_pbs.pl
icinga2 check proxmox backups

## Example output:
```
perl check_raid_ssacli.pl
OK:5 - Failed:0 - Unknown:0
Logicaldrives:
- logicaldrive 1 (1.36 TB, RAID 5): - OK
Physicaldrives:
- physicaldrive 1I:1:1 (port 1I:box 1:bay 1, 500 GB): - OK
- physicaldrive 1I:1:2 (port 1I:box 1:bay 2, 500 GB): - OK
- physicaldrive 1I:1:3 (port 1I:box 1:bay 3, 500 GB): - OK
- physicaldrive 1I:1:4 (port 1I:box 1:bay 4, 600 GB): - OK
```
```
verbose: -- Verbose mode enabled --
verbose: Executing command: ssacli ctrl all show
verbose: Command output: "
Smart Array P212 in Slot 2                (sn: PACCPID112120J0)

"
verbose: Controller: P212 - 2
verbose: Checking logical drives of controller "P212" (Slot 2)
verbose: Executing command: ssacli ctrl slot=2 ld all show status
verbose: Command output: "
   logicaldrive 1 (1.36 TB, RAID 5): OK

"
verbose: logicaldrive 1 (1.36 TB, RAID 5): - OK
verbose: Checking physical drives of controller "P212" (Slot 2)
verbose: Executing command: ssacli ctrl slot=2 pd all show status
verbose: Command output: "
   physicaldrive 1I:1:1 (port 1I:box 1:bay 1, 500 GB): OK
   physicaldrive 1I:1:2 (port 1I:box 1:bay 2, 500 GB): OK
   physicaldrive 1I:1:3 (port 1I:box 1:bay 3, 500 GB): OK
   physicaldrive 1I:1:4 (port 1I:box 1:bay 4, 600 GB): OK

"
verbose: physicaldrive 1I:1:1 (port 1I:box 1:bay 1, 500 GB): - OK
verbose: physicaldrive 1I:1:2 (port 1I:box 1:bay 2, 500 GB): - OK
verbose: physicaldrive 1I:1:3 (port 1I:box 1:bay 3, 500 GB): - OK
verbose: physicaldrive 1I:1:4 (port 1I:box 1:bay 4, 600 GB): - OK
OK:5 - Failed:0 - Unknown:0
Logicaldrives:
- logicaldrive 1 (1.36 TB, RAID 5): - OK
Physicaldrives:
- physicaldrive 1I:1:1 (port 1I:box 1:bay 1, 500 GB): - OK
- physicaldrive 1I:1:2 (port 1I:box 1:bay 2, 500 GB): - OK
- physicaldrive 1I:1:3 (port 1I:box 1:bay 3, 500 GB): - OK
- physicaldrive 1I:1:4 (port 1I:box 1:bay 4, 600 GB): - OK
```

## Installation:
```sh
cd /usr/lib/nagios/plugins
wget https://raw.githubusercontent.com/xmarzl/check_raid_ssacli/main/check_raid_ssacli.pl
chmod 750 /usr/lib/nagios/plugins/check_raid_ssacli.pl
```
Hinzufügen an letzter Stelle der sudoers file:
```vi
visudo
nagios ALL=(root) NOPASSWD: /usr/sbin/ssacli
```

## 

| Parameter         | Description                   |
| ----------------- | ----------------------------- |
| -v  \| --verbose  | More information              |
| -h  \| --help     | This help                     |
| usage | perl check_raid_ssacli.pl [-v] [--help]   |

Example:
```bash
./check_raid_ssacli.pl -v
```
