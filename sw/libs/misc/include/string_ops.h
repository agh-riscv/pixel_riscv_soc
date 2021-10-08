#pragma once

#include <cstdint>

char *strcpy(char *dest, const char *src);
char *strcat(char *dest, const char *src);
int strcmp(const char *str1, const char *str2);
int strlen(const char *str);

void to_dec_string(char *dest, uint32_t word, const uint8_t bytes_number);
void to_dec_string(char *dest, const uint8_t byte);
void to_dec_string(char *dest, const uint32_t word);

void to_hex_string(char *dest, uint32_t word, const uint8_t bytes_number);
void to_hex_string(char *dest, const uint8_t byte);
void to_hex_string(char *dest, const uint32_t word);

void to_string(char *dest, const int val);

bool is_number(const char *str);
int to_int(const char *str);

bool isalnum(const char ch);
