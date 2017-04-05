#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>


#define BUFF_SIZE 4096

static int compress_stream(const char *path, mode_t mode) {
    int fd;
    if ((fd = open(path, O_CREAT | O_WRONLY, mode)) < 0) {
        fprintf(stderr, "failed to create %s: %s\n", path, strerror(errno));
        return -1;
    }

    int pipefd[2];
    pid_t cpid;

    pipe(pipefd);
    signal(SIGPIPE, SIG_IGN);

    cpid = fork();
    if (cpid == -1) {
        fprintf(stderr, "failed to fork: %s\n", strerror(errno));
        return -1;
    }

    if (!cpid) { /* Child reads from pipe */
        char *argv[] = { "gzip", "-f", NULL };
        close(pipefd[1]); /* Close unused write*/
        dup2(pipefd[0], 0);
        dup2(fd, 1); //write to tar fd
        execvp(argv[0], argv);
    } else {
        close(pipefd[0]); /* Close unused read end */
        dup2(pipefd[1], fd); //write to pipe
    }

    return fd;
}

int main(int argc, char *argv[])
{
    int fd;
    char buf[BUFF_SIZE];
    int size;

    if ((fd = compress_stream(argv[1], 0644)) > 0) {
        while ((size = read(0, buf, BUFF_SIZE)) > 0) {
            write(fd, buf, size);
        }
        fsync(fd);
        close(fd);
    }

    return 0;
}
