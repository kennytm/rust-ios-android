#ifndef RUST_REGEX_H_6fc49a24_292a_4eb0_b9a1_bd46ce4efba6
#define RUST_REGEX_H_6fc49a24_292a_4eb0_b9a1_bd46ce4efba6

#if __cplusplus
extern "C" {
#endif

    typedef struct Regex Regex;

    Regex* rust_regex_create(const char* pattern);

    void rust_regex_destroy(Regex* obj);

    int rust_regex_find(const Regex* obj, const char* text);

#if __cplusplus
}
#endif

#endif
