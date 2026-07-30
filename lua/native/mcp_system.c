#if defined(__linux__) && !defined(_GNU_SOURCE)
#define _GNU_SOURCE
#endif
#if defined(__APPLE__) && !defined(_DARWIN_C_SOURCE)
#define _DARWIN_C_SOURCE
#endif
#if !defined(_POSIX_C_SOURCE)
#define _POSIX_C_SOURCE 200809L
#endif

#include <errno.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>

#if defined(__linux__)
#include <sys/random.h>
#endif

#include <lua.h>
#include <lauxlib.h>

#define LINKEDSPEC_MCP_ENTROPY_BYTES 32U
#define LINKEDSPEC_LUA_SAFE_INTEGER UINT64_C(9007199254740991)

static int linkedspec_secure_random_32(lua_State *state) {
    unsigned char bytes[LINKEDSPEC_MCP_ENTROPY_BYTES];

#if defined(__APPLE__) || defined(__FreeBSD__) || defined(__OpenBSD__) || defined(__NetBSD__)
    arc4random_buf(bytes, sizeof(bytes));
#elif defined(__linux__)
    size_t offset = 0U;
    while (offset < sizeof(bytes)) {
        ssize_t count = getrandom(bytes + offset, sizeof(bytes) - offset, 0U);
        if (count < 0 && errno == EINTR) {
            continue;
        }
        if (count <= 0) {
            return luaL_error(state, "linkedspec_mcp_entropy_failure");
        }
        offset += (size_t)count;
    }
#else
#error "LinkedSpec MCP requires arc4random_buf or getrandom"
#endif

    lua_pushlstring(state, (const char *)bytes, sizeof(bytes));
    return 1;
}

static int linkedspec_monotonic_milliseconds(lua_State *state) {
    struct timespec value;
    uint64_t seconds;
    uint64_t milliseconds;

    if (clock_gettime(CLOCK_MONOTONIC, &value) != 0 || value.tv_sec < 0 ||
        value.tv_nsec < 0 || value.tv_nsec >= 1000000000L) {
        return luaL_error(state, "linkedspec_mcp_clock_failure");
    }
    seconds = (uint64_t)value.tv_sec;
    if (seconds > LINKEDSPEC_LUA_SAFE_INTEGER / UINT64_C(1000)) {
        return luaL_error(state, "linkedspec_mcp_clock_failure");
    }
    milliseconds = seconds * UINT64_C(1000) + (uint64_t)value.tv_nsec / UINT64_C(1000000);
    if (milliseconds > LINKEDSPEC_LUA_SAFE_INTEGER) {
        return luaL_error(state, "linkedspec_mcp_clock_failure");
    }
    lua_pushnumber(state, (lua_Number)milliseconds);
    return 1;
}

static const luaL_Reg LINKEDSPEC_MCP_SYSTEM_FUNCTIONS[] = {
    {"secure_random_32", linkedspec_secure_random_32},
    {"monotonic_milliseconds", linkedspec_monotonic_milliseconds},
    {NULL, NULL},
};

int luaopen_linkedspec_mcp_system(lua_State *state) {
#if LUA_VERSION_NUM == 501
    luaL_register(state, "linkedspec_mcp_system", LINKEDSPEC_MCP_SYSTEM_FUNCTIONS);
#else
    luaL_newlib(state, LINKEDSPEC_MCP_SYSTEM_FUNCTIONS);
#endif
    return 1;
}
