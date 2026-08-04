#include <SDL3/SDL_stdinc.h>

void SDL_MemoryBarrierAcquireFunction(void) {}

static SDL_malloc_func malloc_func;
static SDL_calloc_func calloc_func;
static SDL_realloc_func realloc_func;
static SDL_free_func free_func;
static int allocation_count;

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
