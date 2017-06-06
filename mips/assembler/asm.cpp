#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <vector>
#include <string>

#define COUNT_OF(x) \
  ((sizeof(x) / sizeof(0 [x])) / ((size_t)(!(sizeof(x) % sizeof(0 [x])))))

static const int kMaxNameLen = 100;

struct String {
  char *text;
  int len;
};

enum Token_Type {
  Token__Unknown = 0,
  Token__Invalid,
  Token__Label,
  Token__Instruction,
  Token__Register,
  Token__Number,
  Token__Comma,
  Token__Identifier,
  Token__Newline,
};

enum Instruction {
  I__unknown = 0,
  I__add,
  I__and,
  I__balrn,
  I__balrz,
  I__brn,
  I__brz,
  I__jalr,
  I__jr,
  I__nor,
  I__or,
  I__slt,
  I__sll,
  I__srl,
  I__sub,
  I__addi,
  I__andi,
  I__balmn,
  I__balmz,
  I__beq,
  I__beqal,
  I__bmn,
  I__bmz,
  I__bne,
  I__bneal,
  I__jalm,
  I__jalpc,
  I__jm,
  I__jpc,
  I__lw,
  I__ori,
  I__sw,
  I__baln,
  I__balz,
  I__bn,
  I__bz,
  I__jal,
  I__j,

  I__COUNT,
};

// Note: has to be in the same order as the enum above
static const char *g_mnemonics[] = {
    "unknown", "add",   "and",   "balrn", "balrz", "brn", "brz", "jalr",
    "jr",      "nor",   "or",    "slt",   "sll",   "srl", "sub", "addi",
    "andi",    "balmn", "balmz", "beq",   "beqal", "bmn", "bmz", "bne",
    "bneal",   "jalm",  "jalpc", "jm",    "jpc",   "lw",  "ori", "sw",
    "baln",    "balz",  "bn",    "bz",    "jal",   "j",
};

static const char *g_reg_names[] = {
    "zero", "at", "v0", "v1", "a0", "a1", "a2", "a3", "t0", "t1", "t2",
    "t3",   "t4", "t5", "t6", "t7", "s0", "s1", "s2", "s3", "s4", "s5",
    "s6",   "s7", "t8", "t9", "k0", "k1", "gp", "sp", "fp", "ra",
};

static std::vector<std::string> g_symbol_table;

struct Token {
  Token_Type type = Token__Unknown;
  int value = 0;
  int line_num;
};

bool is_whitespace(char c) { return c == ' ' || c == '\t'; }

bool is_alpha(char c) {
  return ('a' <= c && c <= 'z') || ('A' <= c && c <= 'Z');
}

bool is_num(char c) { return ('0' <= c && c <= '9'); }

Instruction match_instruction(char *string) {
  if (strlen(string) > 5) return I__unknown;
  // Linear search, but it's OK
  for (int i = 1; i < COUNT_OF(g_mnemonics); ++i) {
    if (strcmp(g_mnemonics[i], string) == 0) {
      return (Instruction)i;
    }
  }
  return I__unknown;
}

int match_register(char *string) {
  for (int i = 0; i < COUNT_OF(g_reg_names); ++i) {
    if (strcmp(g_reg_names[i], string) == 0) {
      return i;
    }
  }
  return -1;
}

int match_identifier(std::string identifier) {
  int index = 0;
  for (auto &str : g_symbol_table) {
    if (str == identifier) {
      return index;
    }
    index++;
  }
  return -1;
}

int parse_int(char *string) {
  long value = strtol(string, NULL, 0);
  if (value == 0 && strcmp(string, "0") != 0) {
    printf("Warning: parsing %s as 0", string);
  }
  return (int)value;
}

struct Tokenizer {
  int at_ = 0;
  int line_num_ = 1;
  int text_len_;
  char *text_ = NULL;
  std::vector<Token> tokens_;

  Tokenizer(String source) {
    text_ = source.text;
    text_len_ = source.len;
    tokens_.reserve(1000);
  }

  void process_source() {
    while (at_ < text_len_) {
      this->eat_whitespace_and_comments();
      Token token = this->read_token();
      if (token.type == Token__Unknown) {
        printf("Unknown token on line %d\n", line_num_);
        exit(1);
      }
      if (token.type == Token__Invalid) {
        printf("Invalid token on line %d\n", line_num_);
        exit(1);
      }
      tokens_.push_back(token);
    }
  }

  Token read_token() {
    Token token = {};
    token.type = Token__Unknown;
    token.line_num = line_num_;

    if (text_[at_] == '\n') {
      token.type = Token__Newline;
      at_++;
      return token;
    } else if (text_[at_] == ',') {
      token.type = Token__Comma;
      at_++;
      return token;
    }

    // Read token into buffer
    int token_len = 0;
    char buffer[kMaxNameLen];
    while (!is_whitespace(text_[at_]) && text_[at_] != '\n' && text_[at_] != ',') {
      buffer[token_len++] = text_[at_++];
    }
    buffer[token_len] = '\0';
    if (token_len <= 0 || token_len >= kMaxNameLen) {
      token.type = Token__Invalid;
      return token;
    }

    // Recognize the token
    char first_char = buffer[0];
    if (is_alpha(first_char)) {
      char last_char = buffer[token_len - 1];
      if (last_char == ':') {
        token.type = Token__Label;
      } else {
        Instruction instruction = match_instruction(buffer);
        if (instruction == I__unknown) {
          token.type = Token__Identifier;
          std::string identifier = buffer;
          int table_number = match_identifier(identifier);
          if (table_number == -1) {
            g_symbol_table.push_back(identifier);
            table_number = g_symbol_table.size();
          }
          token.value = table_number;
        } else {
          token.type = Token__Instruction;
          token.value = (int)instruction;
        }
      }
    } else if (first_char == '$') {
      token.type = Token__Register;
      int reg_number = match_register(buffer + 1);
      if (reg_number < 0) {
        token.type = Token__Unknown;
      }
      token.value = reg_number;
    } else if (first_char == ',') {
      token.type = Token__Comma;
    } else if (first_char == '\n') {
      token.type = Token__Newline;
      line_num_++;
    } else if (is_num(first_char) || (first_char == '-' && is_num(buffer[1]))) {
      token.type = Token__Number;
      token.value = parse_int(buffer);
    }

    return token;
  }

  void eat_whitespace_and_comments() {
    bool in_comment = false;
    while (at_ < text_len_) {
      char c = text_[at_];
      if (is_whitespace(c) || (in_comment && c != '\n')) {
        at_++;
      } else if (c == '#') {
        at_++;
        in_comment = true;
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
  result.len = size;

  return result;
}

int main(int argc, const char *argv[]) {
  char *filename = (char *)"../mips-pipelined/programs/2_memset_subroutine.mips";
  if (argc == 2) {
    // printf("format: asm <file>\n");
    // return 0;
    filename = (char *)argv[1];
  }
  String source = read_file_into_string(filename);
  if (source.len <= 0) {
    printf("Can't open file %s.", filename);
    return 1;
  }
  Tokenizer tokenizer = Tokenizer(source);
  tokenizer.process_source();

  // TODO: Generate code

  return 0;
}
