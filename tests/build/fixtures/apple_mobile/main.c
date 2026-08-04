#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>
#include <SDL3_image/SDL_image.h>
#include <SDL3_mixer/SDL_mixer.h>
#include <SDL3_net/SDL_net.h>
#include <SDL3_ttf/SDL_ttf.h>

int main(int argc, char **argv)
{
    (void)argc;
    (void)argv;
    if (!SDL_Init(SDL_INIT_EVENTS)) {
        return 1;
    }
    SDL_Quit();
    return 0;
}
