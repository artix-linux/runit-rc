# runit-rc

Artix Linux's implementation of stage 1, stage 3, and one-shot service
handling.

Contains 3 folders:
1. stage1: only executed during system startup by /etc/runit/1, should only contain essential files for startup
2. stage3: only executed during system shutdown by /etc/runit/3, should only contain essential files during shutdown
3. sv.d: executed during stage 2, user-modifiable. static network, netfs mount, binfmt, etc. can be put here, all new one-shot services will also be put here
