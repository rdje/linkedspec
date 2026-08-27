#define PCRE2_CODE_UNIT_WIDTH 8

#include <limits.h>
#include <stdint.h>
#include <string.h>

#include <lauxlib.h>
#include <lua.h>
#include <pcre2.h>

#define LINKEDSPEC_REGEX_MT "linkedspec.regex_pcre2"

typedef struct {
    pcre2_code *code;
    uint32_t capture_count;
} linkedspec_regex;

static linkedspec_regex *check_regex(lua_State *state, int index) {
    return (linkedspec_regex *)luaL_checkudata(state, index, LINKEDSPEC_REGEX_MT);
}

static void set_integer_field(lua_State *state, const char *name, lua_Integer value) {
    lua_pushinteger(state, value);
    lua_setfield(state, -2, name);
}

static int regex_gc(lua_State *state) {
    linkedspec_regex *regex = check_regex(state, 1);
    if (regex->code != NULL) {
        pcre2_code_free(regex->code);
        regex->code = NULL;
    }
    return 0;
}

static int compile_regex(lua_State *state) {
    size_t pattern_length = 0;
    const char *pattern = luaL_checklstring(state, 1, &pattern_length);
    int error_code = 0;
    PCRE2_SIZE error_offset = 0;
    pcre2_code *code = pcre2_compile(
        (PCRE2_SPTR)pattern,
        (PCRE2_SIZE)pattern_length,
        PCRE2_UTF | PCRE2_UCP | PCRE2_DUPNAMES,
        &error_code,
        &error_offset,
        NULL
    );
    if (code == NULL) {
        PCRE2_UCHAR error_buffer[256];
        int message_status = pcre2_get_error_message(error_code, error_buffer, sizeof(error_buffer));
        if (message_status < 0) {
            return luaL_error(
                state,
                "PCRE2 compile error %d at byte %lu",
                error_code,
                (unsigned long)error_offset
            );
        }
        return luaL_error(
            state,
            "PCRE2 compile error at byte %lu: %s",
            (unsigned long)error_offset,
            (const char *)error_buffer
        );
    }

    uint32_t capture_count = 0;
    if (pcre2_pattern_info(code, PCRE2_INFO_CAPTURECOUNT, &capture_count) != 0) {
        pcre2_code_free(code);
        return luaL_error(state, "PCRE2 could not report capture count");
    }

    linkedspec_regex *regex = (linkedspec_regex *)lua_newuserdata(state, sizeof(*regex));
    regex->code = code;
    regex->capture_count = capture_count;
    luaL_getmetatable(state, LINKEDSPEC_REGEX_MT);
    lua_setmetatable(state, -2);
    return 1;
}

static void push_capture(
    lua_State *state,
    const char *input,
    const PCRE2_SIZE *ovector,
    uint32_t capture_index
) {
    PCRE2_SIZE start = ovector[capture_index * 2];
    PCRE2_SIZE finish = ovector[capture_index * 2 + 1];
    if (start == PCRE2_UNSET || finish == PCRE2_UNSET) {
        lua_pushliteral(state, "");
        return;
    }
    lua_pushlstring(state, input + start, (size_t)(finish - start));
}

static void push_capture_span(
    lua_State *state,
    const PCRE2_SIZE *ovector,
    uint32_t capture_index
) {
    lua_newtable(state);
    set_integer_field(state, "start_byte", (lua_Integer)ovector[capture_index * 2]);
    set_integer_field(state, "end_byte", (lua_Integer)ovector[capture_index * 2 + 1]);
}

static void push_named_captures(
    lua_State *state,
    linkedspec_regex *regex,
    const char *input,
    const PCRE2_SIZE *ovector
) {
    uint32_t name_count = 0;
    uint32_t entry_size = 0;
    PCRE2_SPTR name_table = NULL;
    lua_newtable(state);
    if (pcre2_pattern_info(regex->code, PCRE2_INFO_NAMECOUNT, &name_count) != 0 || name_count == 0) {
        return;
    }
    if (pcre2_pattern_info(regex->code, PCRE2_INFO_NAMEENTRYSIZE, &entry_size) != 0 ||
            pcre2_pattern_info(regex->code, PCRE2_INFO_NAMETABLE, &name_table) != 0) {
        return;
    }
    for (uint32_t index = 0; index < name_count; ++index) {
        PCRE2_SPTR entry = name_table + index * entry_size;
        uint32_t capture_index = ((uint32_t)entry[0] << 8) | entry[1];
        PCRE2_SIZE start = ovector[capture_index * 2];
        PCRE2_SIZE finish = ovector[capture_index * 2 + 1];
        if (start == PCRE2_UNSET || finish == PCRE2_UNSET) {
            continue;
        }
        lua_pushlstring(state, input + start, (size_t)(finish - start));
        lua_setfield(state, -2, (const char *)(entry + 2));
    }
}

static int match_regex(lua_State *state) {
    linkedspec_regex *regex = check_regex(state, 1);
    size_t input_length = 0;
    const char *input = luaL_checklstring(state, 2, &input_length);
    lua_Integer raw_offset = luaL_checkinteger(state, 3);
    int anchored = lua_toboolean(state, 4);
    if (raw_offset < 0 || (size_t)raw_offset > input_length) {
        return luaL_error(state, "PCRE2 start byte is outside input");
    }

    pcre2_match_data *match_data = pcre2_match_data_create_from_pattern(regex->code, NULL);
    if (match_data == NULL) {
        return luaL_error(state, "PCRE2 could not allocate match data");
    }
    int match_status = pcre2_match(
        regex->code,
        (PCRE2_SPTR)input,
        (PCRE2_SIZE)input_length,
        (PCRE2_SIZE)raw_offset,
        anchored ? PCRE2_ANCHORED : 0,
        match_data,
        NULL
    );
    if (match_status == PCRE2_ERROR_NOMATCH) {
        pcre2_match_data_free(match_data);
        return 0;
    }
    if (match_status < 0) {
        pcre2_match_data_free(match_data);
        return luaL_error(state, "PCRE2 match error %d", match_status);
    }

    PCRE2_SIZE *ovector = pcre2_get_ovector_pointer(match_data);
    lua_newtable(state);
    set_integer_field(state, "start_byte", (lua_Integer)ovector[0]);
    set_integer_field(state, "end_byte", (lua_Integer)ovector[1]);

    lua_newtable(state);
    for (uint32_t index = 0; index <= regex->capture_count; ++index) {
        push_capture(state, input, ovector, index);
        lua_rawseti(state, -2, (int)index + 1);
    }
    lua_setfield(state, -2, "groups");

    lua_newtable(state);
    int compact_index = 1;
    for (uint32_t index = 1; index <= regex->capture_count; ++index) {
        if (ovector[index * 2] == PCRE2_UNSET || ovector[index * 2 + 1] == PCRE2_UNSET) {
            continue;
        }
        push_capture(state, input, ovector, index);
        lua_rawseti(state, -2, compact_index++);
    }
    lua_setfield(state, -2, "captures");

    lua_newtable(state);
    compact_index = 1;
    for (uint32_t index = 1; index <= regex->capture_count; ++index) {
        if (ovector[index * 2] == PCRE2_UNSET || ovector[index * 2 + 1] == PCRE2_UNSET) {
            continue;
        }
        push_capture_span(state, ovector, index);
        lua_rawseti(state, -2, compact_index++);
    }
    lua_setfield(state, -2, "capture_spans");

    push_named_captures(state, regex, input, ovector);
    lua_setfield(state, -2, "named");
    pcre2_match_data_free(match_data);
    return 1;
}

static int pcre2_version(lua_State *state) {
    PCRE2_UCHAR version[64];
    int status = pcre2_config(PCRE2_CONFIG_VERSION, version);
    if (status < 0) {
        return luaL_error(state, "PCRE2 version query failed");
    }
    lua_pushstring(state, (const char *)version);
    return 1;
}

int luaopen_linkedspec_regex_pcre2(lua_State *state) {
    luaL_newmetatable(state, LINKEDSPEC_REGEX_MT);
    lua_pushcfunction(state, regex_gc);
    lua_setfield(state, -2, "__gc");
    lua_pop(state, 1);

    lua_newtable(state);
    lua_pushcfunction(state, compile_regex);
    lua_setfield(state, -2, "compile");
    lua_pushcfunction(state, match_regex);
    lua_setfield(state, -2, "match");
    lua_pushcfunction(state, pcre2_version);
    lua_setfield(state, -2, "version");
    return 1;
}
