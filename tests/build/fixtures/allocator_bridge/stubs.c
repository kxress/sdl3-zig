#include <SDL3/SDL_stdinc.h>
#include <SDL3/SDL_audio.h>
#include <SDL3/SDL_clipboard.h>
#include <SDL3/SDL_filesystem.h>
#include <SDL3/SDL_locale.h>
#include <SDL3/SDL_log.h>
#include <SDL3/SDL_error.h>
#include <SDL3/SDL_iostream.h>
#include <SDL3/SDL_render.h>
#include <SDL3/SDL_test.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdatomic.h>
#include <stdio.h>
#include <string.h>
#if defined(_WIN32)
#include <malloc.h>
#endif

/*
 * Failure-only symbols used by the complete allocator-wrapper smoke matrix below.  The Linux
 * fake ABI deliberately returns a null pointer (or false in a bool return register) for
 * platform-backed APIs that cannot be meaningfully initialized in this fixture.  Weak aliases
 * keep the declarations sourced from the real SDL headers while avoiding dozens of inert,
 * signature-sensitive C implementations.  Cross-target builds do not execute this matrix.
 */
#if defined(__GNUC__) || defined(__clang__)
static void *fixture_null_allocator_result(void) { return NULL; }
size_t SDL_strlen(const char *source) { (void)source; return 0; }
#pragma GCC diagnostic ignored "-Wattribute-alias"
#pragma weak SDL_iconv_string = fixture_null_allocator_result
#pragma weak SDL_GetAudioPlaybackDevices = fixture_null_allocator_result
#pragma weak SDL_GetAudioRecordingDevices = fixture_null_allocator_result
#pragma weak SDL_GetAudioStreamInputChannelMap = fixture_null_allocator_result
#pragma weak SDL_GetAudioStreamOutputChannelMap = fixture_null_allocator_result
#pragma weak SDL_GetCameras = fixture_null_allocator_result
#pragma weak SDL_GetCameraSupportedFormats = fixture_null_allocator_result
#pragma weak SDL_GetClipboardData = fixture_null_allocator_result
#pragma weak SDL_GetClipboardText = fixture_null_allocator_result
#pragma weak SDL_GetPrimarySelectionText = fixture_null_allocator_result
#pragma weak SDL_GetCurrentDirectory = fixture_null_allocator_result
#pragma weak SDL_GetDisplays = fixture_null_allocator_result
#pragma weak SDL_GetEnvironmentVariables = fixture_null_allocator_result
#pragma weak SDL_GetFullscreenDisplayModes = fixture_null_allocator_result
#pragma weak SDL_GetGamepadBindings = fixture_null_allocator_result
#pragma weak SDL_GetGamepadMapping = fixture_null_allocator_result
#pragma weak SDL_GetGamepadMappingForGUID = fixture_null_allocator_result
#pragma weak SDL_GetGamepadMappingForID = fixture_null_allocator_result
#pragma weak SDL_GetGamepadMappings = fixture_null_allocator_result
#pragma weak SDL_GetGamepads = fixture_null_allocator_result
#pragma weak SDL_GetHaptics = fixture_null_allocator_result
#pragma weak SDL_GetJoysticks = fixture_null_allocator_result
#pragma weak SDL_GetKeyboards = fixture_null_allocator_result
#pragma weak SDL_GetMice = fixture_null_allocator_result
#pragma weak SDL_GetSensors = fixture_null_allocator_result
#pragma weak SDL_GetSurfaceImages = fixture_null_allocator_result
#pragma weak SDL_GetTouchDevices = fixture_null_allocator_result
#pragma weak SDL_GetTouchFingers = fixture_null_allocator_result
#pragma weak SDL_GetWindowICCProfile = fixture_null_allocator_result
#pragma weak SDL_GetWindows = fixture_null_allocator_result
#pragma weak SDL_GlobDirectory = fixture_null_allocator_result
#pragma weak SDL_GlobStorageDirectory = fixture_null_allocator_result
#pragma weak SDL_LoadFile = fixture_null_allocator_result
#pragma weak SDL_LoadFile_IO = fixture_null_allocator_result
#pragma weak SDL_LoadWAV_IO = fixture_null_allocator_result
#pragma weak SDL_ReadProcess = fixture_null_allocator_result
#pragma weak SDL_strdup = fixture_null_allocator_result
#pragma weak SDL_strndup = fixture_null_allocator_result
#pragma weak SDL_wcsdup = fixture_null_allocator_result
#endif

void SDL_MemoryBarrierAcquireFunction(void) {}

static SDL_malloc_func malloc_func;
static SDL_calloc_func calloc_func;
static SDL_realloc_func realloc_func;
static SDL_free_func free_func;
static int allocation_count;
static char last_log[256];
static char last_error[256];
static char last_io[256];
static int last_log_category;
static SDL_LogPriority last_log_priority;
static SDL_LogOutputFunction log_output_function;
static void *log_output_userdata;
static atomic_flag fixture_log_lock = ATOMIC_FLAG_INIT;
static int fixture_log_count;

static void fixture_log_lock_enter(void)
{
    while (atomic_flag_test_and_set_explicit(&fixture_log_lock, memory_order_acquire)) {}
}

static void fixture_log_lock_leave(void)
{
    atomic_flag_clear_explicit(&fixture_log_lock, memory_order_release);
}

void SDL_LogMessage(int category, SDL_LogPriority priority, const char *fmt, ...)
{
    va_list args;
    fixture_log_lock_enter();
    va_start(args, fmt);
    last_log_category = category;
    last_log_priority = priority;
    (void)vsnprintf(last_log, sizeof(last_log), fmt, args);
    va_end(args);
    fixture_log_count += 1;
    fixture_log_lock_leave();
    if (log_output_function != NULL) {
        log_output_function(log_output_userdata, category, priority, last_log);
    }
}

static void fixture_log(int category, SDL_LogPriority priority, const char *fmt, va_list args)
{
    fixture_log_lock_enter();
    last_log_category = category;
    last_log_priority = priority;
    (void)vsnprintf(last_log, sizeof(last_log), fmt, args);
    fixture_log_count += 1;
    fixture_log_lock_leave();
    if (log_output_function != NULL) {
        log_output_function(log_output_userdata, category, priority, last_log);
    }
}

void SDL_Log(const char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    fixture_log(SDL_LOG_CATEGORY_APPLICATION, SDL_LOG_PRIORITY_INFO, fmt, args);
    va_end(args);
}

#define FIXTURE_LOG_PRIORITY(name, priority) \
    void SDL_Log##name(int category, const char *fmt, ...) \
    { \
        va_list args; \
        va_start(args, fmt); \
        fixture_log(category, priority, fmt, args); \
        va_end(args); \
    }

FIXTURE_LOG_PRIORITY(Trace, SDL_LOG_PRIORITY_TRACE)
FIXTURE_LOG_PRIORITY(Verbose, SDL_LOG_PRIORITY_VERBOSE)
FIXTURE_LOG_PRIORITY(Debug, SDL_LOG_PRIORITY_DEBUG)
FIXTURE_LOG_PRIORITY(Info, SDL_LOG_PRIORITY_INFO)
FIXTURE_LOG_PRIORITY(Warn, SDL_LOG_PRIORITY_WARN)
FIXTURE_LOG_PRIORITY(Error, SDL_LOG_PRIORITY_ERROR)
FIXTURE_LOG_PRIORITY(Critical, SDL_LOG_PRIORITY_CRITICAL)

#undef FIXTURE_LOG_PRIORITY

void SDL_SetLogOutputFunction(SDL_LogOutputFunction callback, void *userdata)
{
    log_output_function = callback;
    log_output_userdata = userdata;
}

const char *SDL_test_last_log(void)
{
    return last_log;
}

int SDL_test_last_log_category(void)
{
    return last_log_category;
}

int SDL_test_last_log_priority(void)
{
    return (int)last_log_priority;
}

void SDL_test_reset_log_count(void)
{
    fixture_log_lock_enter();
    fixture_log_count = 0;
    fixture_log_lock_leave();
}

int SDL_test_log_count(void)
{
    int result;
    fixture_log_lock_enter();
    result = fixture_log_count;
    fixture_log_lock_leave();
    return result;
}

bool SDL_SetError(const char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    (void)vsnprintf(last_error, sizeof(last_error), fmt, args);
    va_end(args);
    return false;
}

const char *SDL_GetError(void)
{
    return last_error;
}

bool SDL_ClearError(void)
{
    last_error[0] = '\0';
    return true;
}

struct SDL_IOStream {
    void *memory;
    size_t size;
};

static struct SDL_IOStream fixture_io;

SDL_IOStream *SDL_IOFromMem(void *mem, size_t size)
{
    fixture_io.memory = mem;
    fixture_io.size = size;
    return &fixture_io;
}

size_t SDL_IOprintf(SDL_IOStream *context, const char *fmt, ...)
{
    (void)context;
    va_list args;
    va_start(args, fmt);
    int result = vsnprintf(last_io, sizeof(last_io), fmt, args);
    va_end(args);
    return result < 0 ? 0 : (size_t)result;
}

const char *SDL_test_last_io(void)
{
    return last_io;
}

bool SDL_RenderDebugTextFormat(SDL_Renderer *renderer, float x, float y, const char *fmt, ...)
{
    (void)renderer;
    (void)x;
    (void)y;
    va_list args;
    va_start(args, fmt);
    (void)vsnprintf(last_log, sizeof(last_log), fmt, args);
    va_end(args);
    return true;
}

void SDLTest_LogMessage(SDL_LogPriority priority, const char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    fixture_log(SDL_LOG_CATEGORY_TEST, priority, fmt, args);
    va_end(args);
}

void SDLTest_Log(const char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    fixture_log(SDL_LOG_CATEGORY_TEST, SDL_LOG_PRIORITY_INFO, fmt, args);
    va_end(args);
}

void SDLTest_LogError(const char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    fixture_log(SDL_LOG_CATEGORY_TEST, SDL_LOG_PRIORITY_ERROR, fmt, args);
    va_end(args);
}

static char *fixture_copy(const char *source)
{
    size_t length = 0;
    while (source[length] != '\0') length += 1;
    char *result = SDL_malloc(length + 1);
    if (result == NULL) return NULL;
    for (size_t index = 0; index <= length; index += 1) result[index] = source[index];
    return result;
}

void SDL_test_set_num_allocations(int count)
{
    allocation_count = count;
}

int SDL_GetNumAllocations(void)
{
    return allocation_count;
}

bool SDL_SetMemoryFunctions(SDL_malloc_func new_malloc,
                            SDL_calloc_func new_calloc,
                            SDL_realloc_func new_realloc,
                            SDL_free_func new_free)
{
    malloc_func = new_malloc;
    calloc_func = new_calloc;
    realloc_func = new_realloc;
    free_func = new_free;
    return true;
}

void *SDL_malloc(size_t size)
{
    return malloc_func(size);
}

void *SDL_calloc(size_t nmemb, size_t size)
{
    return calloc_func(nmemb, size);
}

void *SDL_realloc(void *memory, size_t size)
{
    return realloc_func(memory, size);
}

void SDL_free(void *memory)
{
    free_func(memory);
}

void *SDL_aligned_alloc(size_t alignment, size_t size)
{
    size_t rounded = (size + alignment - 1) / alignment * alignment;
#if defined(_WIN32)
    return _aligned_malloc(rounded, alignment);
#else
    return aligned_alloc(alignment, rounded);
#endif
}

void SDL_aligned_free(void *memory)
{
#if defined(_WIN32)
    _aligned_free(memory);
#else
    free(memory);
#endif
}

char *SDL_GetPrefPath(const char *org, const char *app)
{
    (void)org;
    (void)app;
    return fixture_copy("/tmp/sdl-pref/");
}

char **SDL_GetClipboardMimeTypes(size_t *num_mime_types)
{
    const char *first = "text/plain";
    const char *second = "text/uri-list";
    const size_t first_length = strlen(first) + 1;
    const size_t second_length = strlen(second) + 1;
    char **result = SDL_malloc(3 * sizeof(*result) + first_length + second_length);
    if (result == NULL) return NULL;
    char *strings = (char *)(result + 3);
    result[0] = strings;
    memcpy(result[0], first, first_length);
    result[1] = strings + first_length;
    memcpy(result[1], second, second_length);
    result[2] = NULL;
    *num_mime_types = 2;
    return result;
}

SDL_Locale **SDL_GetPreferredLocales(int *count)
{
    SDL_Locale **result = SDL_malloc(2 * sizeof(*result));
    if (result == NULL) return NULL;
    static SDL_Locale first = { "en", "US" };
    static SDL_Locale second = { "pt", NULL };
    result[0] = &first;
    result[1] = &second;
    *count = 2;
    return result;
}

int *SDL_GetAudioDeviceChannelMap(SDL_AudioDeviceID devid, int *count)
{
    (void)devid;
    int *result = SDL_malloc(2 * sizeof(*result));
    if (result == NULL) return NULL;
    result[0] = 0;
    result[1] = 1;
    *count = 2;
    return result;
}

bool SDL_ConvertAudioSamples(
    const SDL_AudioSpec *src_spec,
    const Uint8 *src_data,
    int src_len,
    const SDL_AudioSpec *dst_spec,
    Uint8 **dst_data,
    int *dst_len)
{
    (void)src_spec;
    (void)dst_spec;
    if (src_len < 0) return false;
    *dst_data = SDL_malloc((size_t)src_len);
    if (*dst_data == NULL) return false;
    for (int index = 0; index < src_len; index += 1) (*dst_data)[index] = src_data[index];
    *dst_len = src_len;
    return true;
}

bool SDL_LoadWAV(
    const char *path,
    SDL_AudioSpec *spec,
    Uint8 **audio_buf,
    Uint32 *audio_len)
{
    (void)path;
    spec->freq = 48000;
    spec->format = SDL_AUDIO_S16;
    spec->channels = 2;
    *audio_len = 4;
    *audio_buf = SDL_malloc(*audio_len);
    if (*audio_buf == NULL) return false;
    (*audio_buf)[0] = 1;
    (*audio_buf)[1] = 2;
    (*audio_buf)[2] = 3;
    (*audio_buf)[3] = 4;
    return true;
}

int SDL_asprintf(char **strp, const char *fmt, ...)
{
    char formatted[256];
    va_list args;
    va_start(args, fmt);
    const int result = vsnprintf(formatted, sizeof(formatted), fmt, args);
    va_end(args);
    if (result < 0 || (size_t)result >= sizeof(formatted)) {
        *strp = NULL;
        return -1;
    }
    *strp = fixture_copy(formatted);
    return *strp == NULL ? -1 : result;
}

int SDL_snprintf(char *text, size_t maxlen, const char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    const int result = vsnprintf(text, maxlen, fmt, args);
    va_end(args);
    return result;
}

int SDL_sscanf(const char *text, const char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    if (strcmp(fmt, "%d") == 0) {
        int *value = va_arg(args, int *);
        *value = 42;
        va_end(args);
        return 1;
    }
    const int result = vsscanf(text, fmt, args);
    va_end(args);
    return result;
}
