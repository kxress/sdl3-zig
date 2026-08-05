#include <stddef.h>

size_t sdl_long_double_size(void) {
    return sizeof(long double);
}

size_t sdl_long_double_alignment(void) {
    return _Alignof(long double);
}

long double sdl_long_double_roundtrip(long double value) {
    return value;
}
