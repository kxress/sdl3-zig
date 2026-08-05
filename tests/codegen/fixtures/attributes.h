#define TEST_PRINTF(fmt_index, first_index) \
  __attribute__((format(printf, fmt_index, first_index)))
#define TEST_SCANF(fmt_index, first_index) \
  __attribute__((format(scanf, fmt_index, first_index)))
#define TEST_NORETURN __attribute__((noreturn))
#define TEST_ANALYZER_NORETURN __attribute__((analyzer_noreturn))
#define TEST_ALWAYS_INLINE __attribute__((always_inline)) static __inline__
#define TEST_UNUSED __attribute__((unused))
#define TEST_HIDDEN __attribute__((visibility("hidden")))
#define TEST_FALLTHROUGH __attribute__((fallthrough))
#define TEST_DEPRECATED(message) __attribute__((deprecated(message)))
#define TEST_NODISCARD __attribute__((warn_unused_result))

TEST_PRINTF(1, 2) int attributes_printf(const char *format, ...);
TEST_SCANF(1, 2) int attributes_scanf(const char *format, ...);
TEST_NORETURN void attributes_noreturn(void);
TEST_ANALYZER_NORETURN int attributes_analyzer_noreturn(void);
TEST_ALWAYS_INLINE int attributes_always_inline(int value) { return value; }
static inline int attributes_inline_hint(int value) { return value + 1; }
TEST_UNUSED static int attributes_unused = 1;
int attributes_unused_parameter(int value __attribute__((unused)));
TEST_HIDDEN int attributes_hidden(void);
int attributes_restrict(int *restrict value);
TEST_DEPRECATED("use attributes_replacement instead") int attributes_deprecated(void);
TEST_NODISCARD int attributes_nodiscard(void);
static void attributes_fallthrough(int value) {
  switch (value) {
    case 1:
      TEST_FALLTHROUGH;
    case 2:
      break;
  }
}
