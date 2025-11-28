# LDEV-5944 Status - Linux Service Name Support

## Issue
Linux installer hardcodes `lucee_ctl` service name, preventing multiple Lucee installations side-by-side.

## PR
https://github.com/lucee/lucee-installer/pull/37

## CI Run
https://github.com/lucee/lucee-installer/actions/runs/19765897410

## Changes Made

### 1. Configurable Service Name (LDEV-5944)
- Added `servicename` parameter to installer UI
- Platform defaults: Windows = `Lucee`, Linux = `lucee`
- Linux control script becomes `${servicename}_ctl` (e.g., `lucee_ctl`, `myapp_ctl`)
- Updated `service_config.sh` with `--name` parameter
- Updated `change_user.sh` to accept service name as 4th argument
- Updated `lucee.xml` to use `${servicename}_ctl` everywhere
- Updated uninstaller to use configurable service name

### 2. PR #35 Bug Fixes (merged first)
- Fixed `checkGroupExists()` - was using `id -g` instead of `getent group`
- Fixed `rebuildControlScript()` - `mv` failed on fresh install when file doesn't exist
- Fixed template name mismatch - `lucee.xml` referenced `engine_ctl_template` but PR #35 renamed it to `lucee_ctl_template`

### 3. Fail-Fast Error Handling
- Added `set -e` to `lucee_ctl_template`
- Added `abortOnError` and `onErrorActionList` to lucee.xml for the start command
- Installer now fails immediately with clear error instead of waiting for Tomcat timeout

### 4. `su` Command Fixes
- Problem: Docker containers don't have `su` in PATH or installed
- First attempt: Changed `su` to `/usr/bin/su` - failed on AlmaLinux where `su` is at `/bin/su`
- Second attempt: Changed to `/bin/su` - failed because AlmaLinux `almalinux:latest` doesn't have `util-linux` installed
- Current fix: Added `run_as_owner()` helper function that skips `su` when current user matches target user

## Current `run_as_owner` Implementation
```bash
run_as_owner() {
    if [ "$(id -un)" = "$TOMCAT_OWNER" ]; then
        "$@"
    else
        /bin/su -p -s /bin/sh "$TOMCAT_OWNER" "$@"
    fi
}
```

## CI Test Matrix
| Platform | Container | Users Tested |
|----------|-----------|--------------|
| Ubuntu x64 | Native runner | $USER, root, lucee |
| Ubuntu aarch64 | Native runner | $USER, root, lucee |
| Debian 12 | debian:12 | root, lucee |
| AlmaLinux | almalinux:latest | root, lucee |
| Windows | Native runner | N/A |

## Known Issues

### AlmaLinux CI Workflow Bug
Line 392 in main.yml always uses `--systemuser lucee` regardless of matrix user variable.

### `su` Still Required for Non-Matching Users
When running as root with `--systemuser lucee`, the script still needs `su` which may not be installed in minimal containers.

## Files Modified
- `lucee/lucee.xml` - service name support, fail-fast, template name fix
- `lucee/linux/sys/lucee_ctl_template` - `set -e`, `run_as_owner()` function
- `lucee/linux/sys/change_user.sh` - service name support, getent group fix, mv fix
- `lucee/linux/sys/service_config.sh` - `--name` parameter
- `lucee/translations/messages.en.txt` - renamed message keys

## Next Steps
1. Wait for CI to complete
2. Check failed logs for actual error
3. May need to install `util-linux` in CI workflow for AlmaLinux if `su` is still needed
