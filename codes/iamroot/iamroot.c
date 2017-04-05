/*
 * main.c
 *
 *  Created on: May 12, 2014
 *      Author: zhanghe
 *
 *  How to:
 *      1, get uid and replace uid in code "if (myuid != 1109) {":
 *          $ id
 *          uid=1109(zhanghe)
 *      2, build code:
 *          $ gcc -Wall main.c -o iamroot
 *      3, copy to $PATH, change ower/group/mode, root privileges are required
 *          $ cp iamroot $HOME/bin
 *          # chown root:root $HOME/bin/iamroot
 *          # chmod 6755 $HOME/bin/iamroot
 *
 *  Usage:
 *      $ iamroot cmd...
 *      $ iamroot
 *      # cmd...
 */

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>

int main(int argc, char **argv)
{
    uid_t myuid;

    /* Until we have something better, only 1109 can use iamroot. */
    myuid = getuid();
    if (myuid != 1109) {
        fprintf(stderr, "iamroot: uid %d not allowed to su\n", myuid);
        return 1;
    }

    if (setgid(0) || setuid(0)) {
        fprintf(stderr, "iamroot: permission denied\n");
        return 1;
    }

    if (argc > 1) {
        /* Copy the rest of the args from main. */
        char *exec_args[argc];
        memset(exec_args, 0, sizeof(exec_args));
        memcpy(exec_args, &argv[1], sizeof(exec_args));
        if (execvp(argv[1], exec_args) < 0) {
            int saved_errno = errno;
            fprintf(stderr, "iamroot: exec failed for %s Error:%s\n", argv[1],
                    strerror(errno));
            return -saved_errno;
        }
    }

    /* Default exec shell. */
    execlp("/bin/bash", "bash", NULL);

    fprintf(stderr, "iamroot: exec failed\n");
    return 1;
}
