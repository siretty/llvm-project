// RUN: %clang_cc1 -std=c++2a -fconcepts-ts -x c++ -verify %s

template<typename T> requires sizeof(T) >= 4
bool a() { return false; } // expected-note {{candidate function [with T = unsigned int]}}

template<typename T> requires sizeof(T) >= 4 && sizeof(T) <= 10
bool a() { return true; } // expected-note {{candidate function [with T = unsigned int]}}

bool av = a<unsigned>(); // expected-error {{call to 'a' is ambiguous}}

template<typename T>
concept C1 = sizeof(T) >= 4;

template<typename T> requires C1<T>
constexpr bool b() { return false; }

template<typename T> requires C1<T> && sizeof(T) <= 10
constexpr bool b() { return true; }

static_assert(b<int>());
static_assert(!b<int[10]>());

template<typename T>
concept C2 = sizeof(T) > 1 && sizeof(T) <= 8;

template<typename T>
bool c() { return false; }

template<typename T> requires C1<T>
bool c() { return true; }

template<typename T> requires C1<T>
constexpr bool d() { return false; }

template<typename T>
constexpr bool d() { return true; }

static_assert(!d<int>());

template<typename T>
constexpr int e() { return 1; }

template<typename T> requires C1<T> && C2<T>
constexpr int e() { return 2; }

template<typename T> requires C1<T> || C2<T>
constexpr int e() { return 3; }

static_assert(e<unsigned>() == 2);
static_assert(e<char[10]>() == 3);
static_assert(e<char>() == 1);
