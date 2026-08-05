#if defined(_WIN32)
#define TEST_LINK_IMPORT __declspec(dllimport)
#define TEST_LINK_EXPORT __declspec(dllexport)
#define TEST_LINK_STDCALL __stdcall
#else
#define TEST_LINK_IMPORT __attribute__((visibility("default")))
#define TEST_LINK_EXPORT __attribute__((visibility("default")))
#define TEST_LINK_STDCALL
#endif

TEST_LINK_IMPORT TEST_LINK_STDCALL int attributes_link_imported(int value);
TEST_LINK_EXPORT int attributes_link_exported(void);
