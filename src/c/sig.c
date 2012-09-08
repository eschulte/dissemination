#include <stdlib.h>
#include <locale.h>
#include <gpgme.h>

void bail(gpgme_error_t err, const char * msg){
  if(err){
    printf("%s: [error] %s\n", msg, gpgme_strerror(err));
    exit(err); } }

void init(){
  setlocale (LC_ALL, "");
  gpgme_check_version (NULL);
  gpgme_set_locale (NULL, LC_CTYPE, setlocale (LC_CTYPE, NULL));
  #ifdef LC_MESSAGES
  gpgme_set_locale (NULL, LC_MESSAGES, setlocale (LC_MESSAGES, NULL));
  #endif
  bail(gpgme_engine_check_version(GPGME_PROTOCOL_OpenPGP),
       "Initializing the engine"); }

int main(int argc, char *argv[])
{
  gpgme_ctx_t ctx;
  init();
  bail(gpgme_new(&ctx), "Creating a context");
  printf("success: %s(#%d)\n", argv[0], argc);
  return 0; }
