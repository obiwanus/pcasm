#include <stdio.h>
#include <stdlib.h>

struct string {
  char *memory;
  int len;
};

string read_file_into_string(const char *filename) {
  string result = {};
  FILE *file = fopen(filename, "r");
  if (file == NULL) {
    result.memory = NULL;
    result.len = -1;
    return result;
  }
  int size = 0;
  fseek(file, 0, SEEK_END);
  size = ftell(file);
  fseek(file, 0, SEEK_SET);

  result.memory = (char *)malloc(size * sizeof(char));
  fread(result.memory, size, sizeof(char), file);

  return result;
}

int main(int argc, const char *argv[]) {
  if (argc < 2) {
    printf("format: mips_asm <file>\n");
    return 0;
  }
  const char *filename = argv[1];
  string source = read_file_into_string(filename);

  return 0;
}
