/*
    Copyright (C) 2025 NullPotOS Project
    Follow MIT License
*/

#include <kernel/init/kernel.hpp>

extern "C" auto _start() -> void
{
    _kernelmain();
}