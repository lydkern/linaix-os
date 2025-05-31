/*
    Copyright (C) 2025 NullPotOS Project
    Follow MIT License
*/

#include <kernel/boot/limine/limine.hpp>
#include <kernel/boot/limine/sections.hpp>
#include <kernel/init/kernel.hpp>

USED SECTION(".limine_requests_start") static const
    volatile LIMINE_REQUESTS_START_MARKER;

USED SECTION(".limine_requests_end") static const
    volatile LIMINE_REQUESTS_END_MARKER;

LIMINE_REQUEST LIMINE_BASE_REVISION(2);

LIMINE_REQUEST struct limine_stack_size_request stack_request = {
    .id = LIMINE_STACK_SIZE_REQUEST, .revision = 0, .stack_size = 1024 * 1024};

LIMINE_REQUEST struct limine_entry_point_request entry = {
    .id       = LIMINE_ENTRY_POINT_REQUEST,
    .revision = 3,
    .entry    = &_kernelmain,
};

extern "C" auto _kernelmain() -> void
{
    while (true)
    {
        asm volatile("cli");
        asm volatile("hlt");
    }
}