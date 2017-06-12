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
  Token__OpenParen,
  Token__CloseParen,
};

// Must match above
const char *g_token_types[] = {
    "Unknown", "Invalid",    "Label",   "Instruction", "Register",   "Number",
    "Comma",   "Identifier", "Newline", "OpenParen",   "CloseParen",
};

enum Instruction_Type {
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

  I__RFORMAT,

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

  I__IFORMAT,

  I__baln,
  I__balz,
  I__bn,
  I__bz,
  I__jal,
  I__j,

  I__COUNT,
};

struct Instruction {
  Instruction_Type type;
  short rs;  // register numbers
  short rt;
  short rd;
  short shamt;    // shift amount
  int16_t imm16;  // address/immediate
  int addr26_w;   // 26-bit word address (=> 28-bit byte address)
};

// Note: has to be in the same order as the enum above
static const char *g_mnemonics[] = {
    "unknown", "add",   "and",   "balrn", "balrz", "brn",   "brz", "jalr",
    "jr",      "nor",   "or",    "slt",   "sll",   "srl",   "sub", NULL,
    "addi",    "andi",  "balmn", "balmz", "beq",   "beqal", "bmn", "bmz",
    "bne",     "bneal", "jalm",  "jalpc", "jm",    "jpc",   "lw",  "ori",
    "sw",      NULL,    "baln",  "balz",  "bn",    "bz",    "jal", "j",
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

  const char *repr() { return g_token_types[(int)type]; }
};

bool is_whitespace(char c) { return c == ' ' || c == '\t'; }

bool is_alpha(char c) {
  return ('a' <= c && c <= 'z') || ('A' <= c && c <= 'Z');
}

bool is_token(char c) { return c == '\n' || c == ',' || c == '(' || c == ')'; }

bool is_num(char c) { return ('0' <= c && c <= '9'); }

Instruction_Type match_instruction(char *string) {
  if (strlen(string) > 5) return I__unknown;
  // Linear search, but it's OK
  for (int i = 1; i < COUNT_OF(g_mnemonics); ++i) {
    if (g_mnemonics[i] != NULL && strcmp(g_mnemonics[i], string) == 0) {
      return (Instruction_Type)i;
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

int find_or_add_identifier(std::string identifier) {
  int num = match_identifier(identifier);
  if (num == -1) {
    g_symbol_table.push_back(identifier);
    num = g_symbol_table.size();
  }
  return num;
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

    if (is_token(text_[at_])) {
      char c = text_[at_];
      if (c == '\n') {
        token.type = Token__Newline;
      } else if (c == ',') {
        token.type = Token__Comma;
      } else if (c == '(') {
        token.type = Token__OpenParen;
      } else if (c == ')') {
        token.type = Token__CloseParen;
      } else {
        printf("Token not listed here\n");
        exit(1);
      }
      at_++;
      return token;
    }

    // Read token into buffer
    int token_len = 0;
    char buffer[kMaxNameLen];
    while (!is_whitespace(text_[at_]) && !is_token(text_[at_])) {
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
        buffer[token_len - 1] = '\0';  // delete the colon
        std::string label = buffer;
        token.value = find_or_add_identifier(label);
      } else {
        Instruction_Type instruction = match_instruction(buffer);
        if (instruction == I__unknown) {
          token.type = Token__Identifier;
          std::string identifier = buffer;
          token.value = find_or_add_identifier(identifier);
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

struct CodeGenerator {
  int at_ = 0;
  std::vector<Instruction> instructions_;
  std::vector<Token> tokens_;

  CodeGenerator(std::vector<Token> tokens) {
    instructions_.reserve(100);
    tokens_ = tokens;  // copy but it's ok
  }

  Token get_token() { return tokens_[at_]; }

  bool tokens_left() { return at_ < tokens_.size(); }

  void advance_token() { at_++; }

  int line_num() { return this->get_token().line_num; }

  void check_label() {
    Token token = this->get_token();
    if (token.type == Token__Label) {
      // TODO: Register label
      this->advance_token();
    }
  }

  void eat_newlines() {
    Token token = this->get_token();
    while (token.type == Token__Newline) {
      this->advance_token();
      token = this->get_token();
    }
  }

  Instruction_Type expect_instruction() {
    Token token = this->get_token();
    if (token.type != Token__Instruction) {
      printf("Expected instruction on line %d, got %s\n", this->line_num(),
             token.repr());
      exit(1);
    }
    this->advance_token();
  }

  Instruction read_instruction() {
    Instruction i = {};
    i.type = this->expect_instruction();

    // struct Instruction {
    //   Instruction_Type type;
    //   short rs;  // register numbers
    //   short rt;
    //   short rd;
    //   short shamt;  // shift amount
    //   int16_t imm16;  // address/immediate
    //   int addr26_w;  // 26-bit word address (=> 28-bit byte address)
    // };

    switch (i.type) {
      // ===== R-format

      case I__add:
      case I__and:
      case I__nor:
      case I__or:
      case I__slt:
      case I__sub: {
        // rd, rs, rt
      } break;

      case I__balrn:
      case I__balrz:
      case I__jalr: {
        // rs, rd
      } break;

      case I__brn:
      case I__brz:
      case I__jr: {
        // rs
      } break;

      case I__sll:
      case I__srl: {
        // rd, rt, shamt
      } break;

      // ===== I-format

      case I__addi:
      case I__andi:
      case I__ori: {
        // rt, rs, imm
      } break;

      case I__balmn:
      case I__balmz:
      case I__jalm:
      case I__lw:
      case I__sw: {
        // rt, imm(rs)
      } break;

      case I__beq:
      case I__beqal:
      case I__bne:
      case I__bneal: {
        // rs, rt, offset
      } break;

      case I__bmn:
      case I__bmz:
      case I__jm: {
        // imm(rs)
      } break;

      case I__jalpc: {
        // rt, offset
      } break;

      case I__jpc: {
        // offset
      } break;

      // ===== J-format

      case I__baln:
      case I__balz:
      case I__bn:
      case I__bz:
      case I__jal:
      case I__j: {
        // target26
      } break;

      default: {
        printf("Unknown instruction on line %d", this->line_num());
      } break;
    }
  }

  void read_instructions() {
    while (this->tokens_left()) {
      this->eat_newlines();
      this->check_label();
      Instruction instruction = this->read_instruction();
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
  char *filename =
      (char *)"../mips-pipelined/programs/2_memset_subroutine.mips";
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

  CodeGenerator code = CodeGenerator(tokenizer.tokens_);
  code.read_instructions();

  return 0;
}
