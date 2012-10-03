#include <stdlib.h>
#include <locale.h>
#include <gpgme.h>
#include <string.h>
#include <fcntl.h>

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

void str_to_data(gpgme_data_t *data, const char* string){
  bail(gpgme_data_new_from_mem(data, string, strlen(string), 1),
       "creating a data buffer from memory");
}

void file_to_data(gpgme_data_t *data, const char* file_name){
  int fd = open(file_name, O_RDONLY);
  bail(gpgme_data_new_from_fd(data, fd),
       "creating a data buffer from a file");
}

int main()
{
  gpgme_ctx_t ctx;
  gpgme_data_t SIG, CONTENT;
  gpgme_verify_result_t result;
  gpgme_signature_t sig;
  /*
  const char* sig_str = "-----BEGIN PGP SIGNATURE-----\n"
    "Version: GnuPG v2.0.19 (GNU/Linux)\n"
    "\n"
    "iQEcBAABAgAGBQJQa3thAAoJEDwbhYFhTKBdrwsH/jK7rDbodKgZ1CNdKOjOmsWD\n"
    "tUC+brptZ+y78AwUPKusIv2t3HBcsecxmn8+dGXiXPLZQJ7cIDtAf8gf78/zHzHh\n"
    "nshii5qTYEeMGADTWlMbK9Kdi19t6N3GD6VHm1h2GLuOUi+vRx6WyZ8rPjkcoeR1\n"
    "6MGUHBuxPxMct0N+wKmzM+H+uabL3ysiYAyNpO1Q8m//aw/bqtvsydVsfjFAuzBW\n"
    "nOswdATDkDkQIl+maVsbrW0jJO6Dqp9RxjdKygObeIY7r8xWiqGdto2oV+4FFDQO\n"
    "OyU4jzhtDpGa+jeU8BGRnveiWQgn3Q0NBQnQmrt4rrbKcZAWbsEsfgkCFZhzqYI=\n"
    "=FGNI\n"
    "-----END PGP SIGNATURE-----\n";
  */
  const char* content_str = "patton";

  /* setup */
  init();

  /* create context */
  bail(gpgme_new(&ctx), "Creating a context");

  /* signature */
  file_to_data(&SIG, "/tmp/sig");

  /* content */
  str_to_data(&CONTENT, content_str);
  
  /* verify */
  bail(gpgme_op_verify(ctx, SIG, CONTENT, NULL), "verifying");

  /* view the result */
  result = gpgme_op_verify_result (ctx);
  sig = result->signatures;
  do {
  if (sig->status == GPG_ERR_NO_ERROR)
    printf("verified\n");
  else
    printf("not verified: %s\n", gpgme_strerror(sig->status));
  } while (sig->next);

  return 0;
}
