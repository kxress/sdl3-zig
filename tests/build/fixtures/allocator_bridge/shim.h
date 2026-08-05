#define SDL_DISABLE_OLD_NAMES 1
#include <SDL3/SDL.h>
#include <SDL3/SDL_revision.h>
#include <SDL3/SDL_test.h>

const char *SDL_test_last_log(void);
int SDL_test_last_log_category(void);
int SDL_test_last_log_priority(void);
void SDL_test_reset_log_count(void);
int SDL_test_log_count(void);
const char *SDL_test_last_io(void);
