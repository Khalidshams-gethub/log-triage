# log-triage
# SSH Log Triage Script

This repo contains a small Bash script that reads an SSH log file and shows failed login attempts in a clear way.

---

## About

My name is **[Khalid Shams]**.  
I am a student in **IT 135 Linux**.  
This project is for class and also for my portfolio.

---

## Problem

Linux auth logs can be long and hard to read.  
There are many lines like:

- `Failed password for root from 172.20.1.1 ...`

It is not easy to see:

- how many times someone tried to log in  
- which IP addresses are attacking the server

---

## What the script does

File: `log-triage.sh`

It:

1. Reads an SSH/auth log file  
   - default: `sample_logs/auth.log`
2. Finds all lines with `Failed password for`  
3. Saves them to `output/ssh_failed.log`
4. Counts how many failures for each `user@ip`
5. Writes the summary to `output/summary.txt`

Example summary line:

```text
root@172.20.1.6    1890
