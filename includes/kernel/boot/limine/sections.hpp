/*
    Copyright (C) 2025 NullPotOS Project
    Follow MIT License
*/

#pragma once

#define _attr(...) __attribute__((__VA_ARGS__))
#define _wur __attribute__((warn_unused_result))
#define _rest __restrict
#define _throw _attr(nothrow, leaf)

#define USED _attr(used)
#define SECTION(name) _attr(section(name))
#define LIMINE_REQUEST USED SECTION(".limine_requests") static volatile