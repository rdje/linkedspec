#include <errno.h>
#include <string.h>
#include <sys/stat.h>

#include <lauxlib.h>
#include <lua.h>

#ifdef _WIN32
typedef struct _stat64 linkedspec_stat_buffer;
#define LINKEDSPEC_STAT _stat64
#define LINKEDSPEC_IS_REGULAR(mode) (((mode) & _S_IFMT) == _S_IFREG)
#else
typedef struct stat linkedspec_stat_buffer;
#define LINKEDSPEC_STAT stat
#define LINKEDSPEC_IS_REGULAR(mode) S_ISREG(mode)
#endif

static void set_string_field(lua_State *state, const char *name, const char *value) {
    lua_pushstring(state, value);
    lua_setfield(state, -2, name);
}

static int inspect_path(lua_State *state) {
    size_t path_length = 0;
    const char *path = luaL_checklstring(state, 1, &path_length);
    if (path_length == 0 || memchr(path, '\0', path_length) != NULL) {
        return luaL_error(state, "filesystem path must be a non-empty string without NUL bytes");
    }

    linkedspec_stat_buffer metadata;
    errno = 0;
    if (LINKEDSPEC_STAT(path, &metadata) == 0) {
        lua_newtable(state);
        set_string_field(
            state,
            "status",
            LINKEDSPEC_IS_REGULAR(metadata.st_mode) ? "file" : "non_regular"
        );
        return 1;
    }

    int error_number = errno;
    lua_newtable(state);
    if (error_number == ENOENT || error_number == ENOTDIR) {
        set_string_field(state, "status", "missing");
        return 1;
    }
    set_string_field(state, "status", "error");
    set_string_field(state, "detail", strerror(error_number));
    return 1;
}

int luaopen_linkedspec_filesystem_native(lua_State *state) {
    lua_newtable(state);
    lua_pushcfunction(state, inspect_path);
    lua_setfield(state, -2, "inspect");
    return 1;
}
