#include <stdio.h>
#include <stdlib.h>
#include <vector>

struct String {
  char *text;
  int len;
};

enum Token_Type {
  Token__Label,
  Token__Command,
  Token__Register,
  Token__Number,
  Token__Comma,
  Token__Identifier,
};

struct Token {};

struct Tokenizer {
  int at_ = 0;
  int line_num_ = 1;
  int text_len_;
  char *text_ = NULL;
  std::vector<Token> tokens_;

  Tokenizer(String source) {
    text_ = source.text;
    text_len_ = source.len;
  }

  Token *process_source() {
    while (at_ < text_len_) {
      this->eat_whitespace();
      this->read_token();
    }
  }

  void read_token() {
    const int kMaxNameLen = 100;
    int token_len = 0;
    char buffer[kMaxNameLen];
    while (!this->is_whitespace(text_[at_]) && text_[at_] != ':') {
      buffer[token_len++] = text_[at_++];
    }
    buffer[token_len] = '\0';
  }

  bool is_whitespace(char c) {
    return c == ' ' || c == '\t' || c == '\n';
  }

  void eat_whitespace() {
    while (at_ < text_len_) {
      char c = text_[at_];
      if (this->is_whitespace(c)) {
        at_++;
        if (c == '\n') line_num_++;
      } else {
        break;
      }
    }
  }
};

String read_file_into_string(const char *filename) {
  String result = {};
  FILE *file = fopen(filename, "r");
  if (file == NULL) {
    result.text = NULL;
    result.len = -1;
    return result;
  }
  int size = 0;
  fseek(file, 0, SEEK_END);
  size = ftell(file);
  fseek(file, 0, SEEK_SET);

  result.text = (char *)malloc(size * sizeof(char));
  fread(result.text, size, sizeof(char), file);

  return result;
}

int main(int argc, const char *argv[]) {
  if (argc < 2) {
    printf("format: mips_asm <file>\n");
    return 0;
  }
  const char *filename = argv[1];
  String source = read_file_into_string(filename);
  Tokenizer tokenizer = Tokenizer(source);
  Token *tokens = tokenizer.process_source();

  return 0;
}
