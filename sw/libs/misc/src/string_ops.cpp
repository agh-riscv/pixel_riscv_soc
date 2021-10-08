#include "string_ops.h"

static char *find_first_non_zero_digit(char *str)
{
    while (*str == '0')
        ++str;
    /* If the string contains only zeros, return the last one */
    return *str ? str : str - 1;
}

char *strcpy(char *dest, const char *src)
{
    char *tmp{dest};
    while ((*dest++ = *src++) != '\0') { }
    return tmp;
}

char *strcat(char *dest, const char *src)
{
    char *tmp{dest};
    while (*dest)
        dest++;
    while ((*dest++ = *src++) != '\0') { }
    return tmp;
}

int strcmp(const char *str1, const char *str2)
{
    while (1) {
        if (*str1 != *str2)
            return *str1 < *str2 ? -1 : 1;
        else if (!*str1)
            return 0;
        ++str1;
        ++str2;
    }
}

int strlen(const char *str)
{
    int len{0};
    while (*str++)
        ++len;
    return len;
}

void to_dec_string(char *dest, uint32_t word, const uint8_t bytes_number)
{
    uint32_t divider;
    switch (bytes_number) {
    case 1:
        divider = 100;
        break;
    case 2:
        divider = 10000;
        break;
    case 4:
        divider = 1000000000;
        break;
    default:
        divider = 0;
        break;
    }

    for( ; divider >= 1; divider /= 10) {
        *dest = word / divider;
        word -= *dest * divider;
        *dest++ += '0';
    }
    *dest = '\0';
}

void to_dec_string(char *dest, const uint8_t byte)
{
    to_dec_string(dest, byte, 1);
}

void to_dec_string(char *dest, uint32_t word)
{
    char buf[11];
    to_dec_string(buf, word, 4);
    strcpy(dest, find_first_non_zero_digit(buf));
}

void to_hex_string(char *dest, uint32_t word, const uint8_t bytes_number)
{
    const uint8_t nibbles_number{static_cast<uint8_t>(2 * bytes_number)};
    dest[0] = '0';
    dest[1] = 'x';
    for (int i = nibbles_number; i > 0; --i) {
        uint8_t nibble{static_cast<uint8_t>(word & 0x0f)};
        dest[1 + i] = (nibble < 10) ? '0' + nibble : 'a' + nibble - 10;
        word >>= 4;
    }
    dest[nibbles_number + 2] = '\0';
}

void to_hex_string(char *dest, const uint8_t byte)
{
    to_hex_string(dest, byte, 1);
}

void to_hex_string(char *dest, const uint32_t word)
{
    to_hex_string(dest, word, 4);
}

void to_string(char *dest, const int val)
{
    char buf[11];
    if (val < 0) {
        dest[0] = '-';
        to_dec_string(buf, -val, 4);
        strcpy(&dest[1], find_first_non_zero_digit(buf));
    } else {
        to_dec_string(buf, val, 4);
        strcpy(dest, find_first_non_zero_digit(buf));
    }
}

static bool is_dec_digit(const char c)
{
    return (c >= '0' && c <= '9');
}

static bool is_dec_number(const char *str)
{
    if (*str == '-')
        ++str;

    do {
        if (!is_dec_digit(*str))
            return false;
    } while (*++str);
    return true;
}

static bool is_hex_digit(const char c)
{
    return (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F');
}

static bool is_hex_number(const char *str)
{
    if (str[0] != '0' || str[1] != 'x')
        return false;

    str += 2;
    do {
        if (!is_hex_digit(*str))
            return false;
    } while (*++str);
    return true;
}

bool is_number(const char *str)
{
    return is_dec_number(str) || is_hex_number(str);
}

static int dec_to_int(const char *str)
{
    bool neg{false};
    if (*str == '-') {
        neg = true;
        ++str;
    }

    int val{0};
    while (*str) {
        val *= 10;
        val += *str++ - '0';
    }
    return neg ? -val : val;
}

static int hex_to_int(const char *str)
{
    if (str[0] != '0' || str[1] != 'x')
        return 0xdeadbeef;

    int val{0};
    const char *hex_digit = &str[2];
    while (*hex_digit) {
        uint8_t nibble;
        if (*hex_digit >= 'a')
            nibble  = *hex_digit - 'a' + 10;
        else if (*hex_digit >= 'A')
            nibble  = *hex_digit - 'A' + 10;
        else
            nibble =  *hex_digit - '0';

        val = val<<4 | nibble;
        ++hex_digit;
    }
    return val;
}

int to_int(const char *str)
{
    if (is_dec_number(str))
        return dec_to_int(str);
    else if (is_hex_number(str))
        return hex_to_int(str);
    else
        return 0xdeadbeef;
}

bool isalnum(const char ch)
{
    return (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || (ch >= '0' && ch <= '9');
}
