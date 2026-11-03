"""Builds bucket_test.cpp from the real BucketName/Present/Buckets in pc_assets.cpp, with stubs."""
import re, sys
src = open(sys.argv[1]).read()
a = src.index("/* t30: a name's bucket folder under Data")
b = src.index("void Assets::MakeDirs(const char *rel) {")
body = src[a:b]
head = r'''
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <strings.h>
#include <sys/stat.h>
#include <unistd.h>
#include <time.h>
#include <string>
#define MAX_PATH 260
#define PC_SEP "/"
#define _stricmp strcasecmp
static int g_renameLimit = -1, g_renames = 0;
static int test_rename(const char *a, const char *b) {
    if (g_renameLimit >= 0 && g_renames >= g_renameLimit) return -1;   /* "the power went" */
    g_renames++;
    return rename(a, b);
}
#define rename test_rename
static void PC_Log(const char *fmt, ...) {}
namespace os {
bool IsFile(const char *p) { struct stat st; return stat(p, &st) == 0 && S_ISREG(st.st_mode); }
void PathFix(char *p) { for (; *p; p++) if (*p == '\\') *p = '/'; }
void MakeDirs(const char *p) { mkdir(p, 0777); }
int64_t ClockFreq() { return 1000000; }
int64_t ClockNow() { struct timespec t; clock_gettime(CLOCK_MONOTONIC, &t); return (int64_t)t.tv_sec * 1000000 + t.tv_nsec / 1000; }
}
struct Assets {
    char m_root[MAX_PATH];
    const char *Root() { return m_root; }
    void Path(char *out, int n, const char *rel) { snprintf(out, n, "%s" PC_SEP "%s", Root(), rel); os::PathFix(out); }
    void MakeDirs(const char *rel) { char p[MAX_PATH]; Path(p, sizeof p, rel); os::MakeDirs(p); }
    void Buckets();
    bool Present(const char *rel, char *path, int n);
};
'''
tail = r'''
int main(int argc, char **argv) {
    /* argv: root manifest-entry-count limit mode check */
    Assets as;
    snprintf(as.m_root, sizeof as.m_root, "%s", argv[1]);
    g_renameLimit = atoi(argv[2]);
    if (!strcmp(argv[3], "check")) {
        /* every manifest file found by Present */
        char path[MAX_PATH], line[MAX_PATH], mp[MAX_PATH];
        as.Path(mp, sizeof mp, "Manifest.txt");
        FILE *f = fopen(mp, "r");
        int n = 0, bad = 0;
        while (fgets(line, sizeof line, f)) {
            line[strcspn(line, "\r\n")] = 0;
            if (!line[0] || line[0] == '#') continue;
            n++;
            if (!as.Present(line, path, sizeof path)) { bad++; printf("MISSING %s\n", line); }
        }
        fclose(f);
        printf("check: %d listed, %d missing\n", n, bad);
        return bad != 0;
    }
    setenv("THPS_DATA_BUCKETS", argv[3], 1);
    as.Buckets();
    printf("renames done: %d\n", g_renames);
    return 0;
}
'''
open(sys.argv[2], "w").write(head + body.replace("#ifdef __vita__", "#if 1") + tail)
print("ok")
