#include <lua5.1/lua.h>
#include <lua5.1/lualib.h>
#include <lua5.1/lauxlib.h>

#include <stddef.h>
#include <cotp.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#define DIGIT_COUNT 6
#define CODE_DURATION_SECS 30
#define CODE_GEN_ALGO SHA1

int libtotp_gen_totp_code(lua_State *L)
{
    //
    // We expect the first argument is the auth key
    //
    if (!lua_isstring(L, 1))
    {
        return luaL_error(L, "First argument to `gen_totp_code` should be a string");
    }

    const char *auth_key = lua_tostring(L, 1);

    cotp_error_t err_code;
    const char *otp_code = get_totp(
        auth_key,
        DIGIT_COUNT,
        CODE_DURATION_SECS,
        CODE_GEN_ALGO,
        &err_code);
    
    if (!otp_code)
    {
        return luaL_error(L, "Failed to generate TOTP code");
    }

    const size_t otp_code_len = strnlen(otp_code, 16);
    lua_pushlstring(L, otp_code, otp_code_len);

    return 1;
}


static const struct luaL_Reg lib_reg[] = {
    {"gen_totp_code", libtotp_gen_totp_code},
    {NULL, NULL}};

int luaopen_libtotp(lua_State *L)
{
    luaL_register(L, "libtotp", lib_reg);
    return 1;
}