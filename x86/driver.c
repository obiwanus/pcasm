#if defined(__GNUC__)
#  define PRE_CDECL
#  define POST_CDECL __attribute__((cdecl))
#else
#  define PRE_CDECL __cdecl
#  define POST_CDECL
#endif

int PRE_CDECL asm_main( void ) POST_CDECL;

int main()
{
  int ret_status;
  ret_status = asm_main();
  return ret_status;
}
