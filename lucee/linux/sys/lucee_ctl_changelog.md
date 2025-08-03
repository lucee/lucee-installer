# lucee_ctl changelog

## 2025-08-03

1. Performance optimizations: restart is faster because it doesn't arbitrarily wait 5 seconds when the server may have stopped much quicker than that; startup confirmation exits immediately upon success instead of waiting fixed time; stop is faster due to refactoring of redundant findpid calls; proactive stale PID cleanup prevents unnecessary process check.

2. Replaced `findpid()` with the more semantically correct `checkisrunning()`, which first deletes stale PID file from server reboot.

3. `start()` function now confirms whether the server is running (with 10 second timeout) and provides proper success/failure feedback instead of just assuming it worked.

4. `stop()` function now waits for graceful shutdown and provides better timeout messaging when forcing a kill.

5. `status()` function enhanced to show not just the PID but also "has been running since" datetime.

6. Added a proper `restart()` function that waits for confirmation of shutdown before starting again, replacing the old "stop, sleep 5, start" approach.

7. Improved error handling and user feedback throughout with more descriptive messages and exit status checking.

8. Removed support for environments that don't have JRE installed because it is bundled with Lucee installer. That resulted in removal of substitution patterns `@@luceeJREhome@@` and `@@luceeJAVAhome@@` in lucee.xml which means change_user.sh can be tested independently of building the installer.

9. Removed support for OpenBD while remaining backward compatible with legacy automated workflows as long as the engine argument is set to "lucee".

10. Refactored if statements to use [[ ... ]] (bash conditional) instead of [ ... ] (POSIX) and double quotes around variables to prevent word splitting and globbing.

11. Improved Usage statement by removing brackets around username argument because it is not optional.

12. Changed `rm -rf` to `rm -f` because -r (recursive) applies only to directories.
