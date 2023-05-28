//
//  Operations.swift
//  Sandstone
//
//  Created by Spotlight Deveaux on 2022-07-24.
//

import Foundation

/// SandboxOperations represents the list of
/// sandbox operations for macOS 13.0 (22A5295i).
///
/// !!!! TODO: REMOVE !!!!
/// This list varies so heavily across versions it's not funny.
/// It should be specified by the user - or better yet, extracted
/// from the kernel itself. If.. possible, I guess. That'd be nice.
public let SandboxOperations = [
    "default",
    "appleevent-send",
    "authorization-right-obtain",
    "boot-arg-set",
    "device*",
    "device-camera",
    "device-microphone",
    "darwin-notification-post",
    "distributed-notification-post",
    "dynamic-code-generation",
    "file*",
    "file-chroot",
    "file-clone",
    "file-ioctl",
    "file-issue-extension",
    "file-link",
    "file-map-executable",
    "file-mknod",
    "file-mount",
    "file-mount-update",
    "file-read*",
    "file-read-data",
    "file-read-metadata",
    "file-read-xattr",
    "file-revoke",
    "file-search",
    "file-test-existence",
    "file-unmount",
    "file-write*",
    "file-write-acl",
    "file-write-create",
    "file-write-data",
    "file-write-finderinfo",
    "file-write-flags",
    "file-write-mode",
    "file-write-owner",
    "file-write-setugid",
    "file-write-times",
    "file-write-unlink",
    "file-write-xattr",
    "fs-quota*",
    "fs-quota-get",
    "fs-quota-on",
    "fs-quota-off",
    "fs-quota-set*",
    "fs-quota-set-limits",
    "fs-quota-set-usage",
    "fs-quota-stat",
    "fs-quota-sync",
    "fs-rename",
    "fs-snapshot*",
    "fs-snapshot-create",
    "fs-snapshot-delete",
    "fs-snapshot-mount",
    "fs-snapshot-revert",
    "generic-issue-extension",
    "qtn-user",
    "hid-control",
    "iokit*",
    "iokit-get-properties",
    "iokit-issue-extension",
    "iokit-open*",
    "iokit-open-user-client",
    "iokit-open-service",
    "iokit-set-properties",
    "ipc*",
    "ipc-posix*",
    "ipc-posix-issue-extension",
    "ipc-posix-sem*",
    "ipc-posix-sem-create",
    "ipc-posix-sem-open",
    "ipc-posix-sem-post",
    "ipc-posix-sem-unlink",
    "ipc-posix-sem-wait",
    "ipc-posix-shm*",
    "ipc-posix-shm-read-data",
    "ipc-posix-shm-write*",
    "ipc-posix-shm-write-create",
    "ipc-posix-shm-write-data",
    "ipc-posix-shm-write-unlink",
    "ipc-sysv*",
    "ipc-sysv-msg",
    "ipc-sysv-sem",
    "ipc-sysv-shm",
    "job-creation",
    "lsopen",
    "mach*",
    "mach-bootstrap",
    "mach-cross-domain-lookup",
    "mach-derive-port",
    "mach-host*",
    "mach-host-exception-port-set",
    "mach-host-special-port-set",
    "mach-issue-extension",
    "mach-kernel-endpoint",
    "mach-lookup",
    "mach-priv*",
    "mach-priv-host-port",
    "mach-priv-task-port",
    "mach-register",
    "mach-task*",
    "mach-task-inspect",
    "mach-task-name",
    "mach-task-read",
    "mach-task-special-port*",
    "mach-task-special-port-get",
    "mach-task-special-port-set",
    "necp-client-open",
    "network*",
    "network-inbound",
    "network-bind",
    "network-outbound",
    "nvram*",
    "nvram-delete",
    "nvram-get",
    "nvram-set",
    "opendirectory-user-modify",
    "process*",
    "process-codesigning*",
    "process-codesigning-blob-get",
    "process-codesigning-cdhash-get",
    "process-codesigning-entitlements-blob-get",
    "process-codesigning-entitlements-der-blob-get",
    "process-codesigning-identity-get",
    "process-codesigning-status*",
    "process-codesigning-status-set",
    "process-codesigning-status-get",
    "process-codesigning-teamid-get",
    "process-codesigning-text-offset-get",
    "process-exec*",
    "process-exec-interpreter",
    "process-fork",
    "process-info*",
    "process-info-codesignature",
    "process-info-dirtycontrol",
    "process-info-ledger",
    "process-info-listpids",
    "process-info-rusage",
    "process-info-pidinfo",
    "process-info-pidfdinfo",
    "process-info-pidfileportinfo",
    "process-info-setcontrol",
    "pseudo-tty",
    "signal",
    "socket-ioctl",
    "socket-option*",
    "socket-option-get",
    "socket-option-set",
    "syscall*",
    "syscall-unix",
    "syscall-mach",
    "syscall-mig",
    "sysctl*",
    "sysctl-read",
    "sysctl-write",
    "system*",
    "system-acct",
    "system-audit",
    "system-automount",
    "system-debug",
    "system-fcntl",
    "system-fsctl",
    "system-info",
    "system-kext*",
    "system-kext-load",
    "system-kext-unload",
    "system-kext-query",
    "system-mac*",
    "system-mac-label",
    "system-mac-syscall",
    "system-memorystatus-control",
    "system-necp-client-action",
    "system-nfssvc",
    "system-package-check",
    "system-privilege",
    "system-reboot",
    "system-sched",
    "system-set-time",
    "system-socket",
    "system-suspend-resume",
    "system-swap",
    "user-preference*",
    "user-preference-read",
    "managed-preference-read",
    "user-preference-write",
    "storage-class-map",
]
